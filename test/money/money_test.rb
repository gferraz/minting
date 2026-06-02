using Mint

class MoneyTest < Minitest::Test
  def test_its_contructors
    assert_instance_of Mint::Money, Mint.money(100, 'USD')
    assert_predicate Mint.money(100, 'USD'), :frozen?

    assert_raises(ArgumentError) { Mint.money('b', 'USD') }
    assert_raises(ArgumentError) { Mint.money(10r, Object.new) }
    assert_raises(ArgumentError) { Mint.money(1, 'NOT_A_CURRENCY') }
  end

  def test_amount
    assert_equal 100, Mint.money(100, 'USD').amount
    assert_equal 1,   Mint.money(1, 'USD').amount
    assert_equal 14,  Mint.money(14, Mint.currency('PEN')).amount
  end

  def test_hash
    assert_equal Mint.money(2, 'USD').hash, Mint.money(2, 'USD').hash
    refute_equal Mint.money(2, 'USD').hash, Mint.money(0, 'USD').hash
    refute_equal Mint.money(2, 'USD').hash, Mint.money(2, 'BRL').hash
  end

  def test_inspect
    assert_equal '[USD 10.34]', Mint.money(10.34, 'USD').inspect
  end

  def test_same_currency
    assert 10.34.mint('USD').same_currency?(Mint.money(100, 'USD'))
    refute 10.34.mint('USD').same_currency?(30)
    refute 10.34.mint('USD').same_currency?(Mint.money(10.34, 'BRL'))
  end

  def test_zero
    zero = Mint.zero
    zero_soles = Mint.money(0r, Mint.currency('PEN'))

    assert_predicate 0.dollars, :zero?
    assert_equal 0.dollars, zero_soles
    assert_equal 0, 0.dollars
    assert_equal 0, 0.dollars
    assert_equal zero, 0.dollars
    refute_predicate Mint.money(100r, 'USD'), :zero?
  end

  def test_nonzero
    two_soles = Mint.money(2, Mint.currency('PEN'))

    assert_predicate 2.dollars, :nonzero?
    refute_equal 2.dollars, two_soles
    refute_equal 0, 2.dollars
    refute_equal 2.dollars, 0
  end

  def test_creation
    assert Mint::Money.new(3, Mint.currency('PEN'))
    assert_raises(ArgumentError) { Mint::Money.create('334.2', Mint.currency('PEN')) }
    assert_raises(ArgumentError) { Mint::Money.create(3, Object.new) }
  end

  def test_fractional
    assert_equal 123_456, Mint.money(1234.56, 'USD').fractional
    assert_equal 123_00, Mint.money(123, 'USD').fractional
    assert_equal 123_99, Mint.money(123.9912, 'USD').fractional
  end

  def test_from_fractional
    # Subunit 2: USD cents
    assert_equal Mint.money(1234.56, 'USD'),
                 Mint::Money.from_fractional(123_456, 'USD')
    assert_equal Mint.money(0, 'USD'),
                 Mint::Money.from_fractional(0, 'USD')
    assert_equal Mint.money(0.01, 'USD'),
                 Mint::Money.from_fractional(1, 'USD')

    # Subunit 0: JPY yen (multiplier == 1)
    assert_equal Mint.money(1234, 'JPY'),
                 Mint::Money.from_fractional(1234, 'JPY')
    assert_equal Mint.money(0, 'JPY'),
                 Mint::Money.from_fractional(0, 'JPY')

    # Subunit 3: IQD fils (multiplier == 1000)
    assert_equal Mint.money(123.456, 'IQD'),
                 Mint::Money.from_fractional(123_456, 'IQD')

    # Accepts Symbol and Currency
    assert_equal Mint.money(1, 'USD'),
                 Mint::Money.from_fractional(100, :USD)
    assert_equal Mint.money(1, 'USD'),
                 Mint::Money.from_fractional(100, Mint.currency('USD'))
  end

  def test_from_fractional_round_trip
    [9.99, 100, 0, 0.01, 1_234_567.89].each do |amount|
      m = Mint.money(amount, 'USD')

      assert_equal m, Mint::Money.from_fractional(m.fractional, 'USD'),
                   "round trip failed for #{amount}"
    end
  end

  def test_from_fractional_rejects_non_integer
    assert_raises(ArgumentError) { Mint::Money.from_fractional(1.5, 'USD') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional('100', 'USD') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100r, 'USD') }
  end

  def test_from_fractional_rejects_unknown_currency
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100, 'ZZZ') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100, Object.new) }
  end

  # --- Money#clamp(min, max) (recommendation P1-2) ---

  def test_clamp_in_range_returns_self
    money = Mint.money(5, 'USD')

    assert_equal money, money.clamp(Mint.money(0, 'USD'), Mint.money(10, 'USD'))
    assert_same money, money.clamp(0, 10),
                'in-range clamp must return self, not a new equal-valued Money'
  end

  def test_clamp_below_min_returns_min
    money = Mint.money(-5, 'USD')

    assert_equal Mint.money(0, 'USD'),
                 money.clamp(Mint.money(0, 'USD'), Mint.money(10, 'USD'))
    assert_equal Mint.money(0, 'USD'), money.clamp(0, 10)
  end

  def test_clamp_above_max_returns_max
    money = Mint.money(50, 'USD')

    assert_equal Mint.money(10, 'USD'),
                 money.clamp(Mint.money(0, 'USD'), Mint.money(10, 'USD'))
    assert_equal Mint.money(10, 'USD'), money.clamp(0, 10)
  end

  def test_clamp_at_boundary_returns_self
    # Clamp at the lower bound is in-range, so the receiver is returned.
    at_min = Mint.money(0, 'USD')

    assert_same at_min, at_min.clamp(0, 10)

    # Clamp at the upper bound is also in-range.
    at_max = Mint.money(10, 'USD')

    assert_same at_max, at_max.clamp(0, 10)
  end

  def test_clamp_accepts_money_bounds
    money = Mint.money(5, 'USD')

    assert_equal Mint.money(5, 'USD'),
                 money.clamp(Mint.money(0, 'USD'), Mint.money(10, 'USD'))
  end

  def test_clamp_accepts_numeric_bounds
    # The common "price.clamp(0, 100)" idiom: Numeric is interpreted
    # as an amount in self's currency.
    money = Mint.money(50, 'USD')

    assert_equal Mint.money(100, 'USD'), money.clamp(0, 100)
  end

  def test_clamp_mixed_bound_types
    # One bound is Money, the other is Numeric. Both should work.
    money = Mint.money(50, 'USD')

    assert_equal Mint.money(10, 'USD'),
                 money.clamp(0, Mint.money(10, 'USD'))
    assert_equal Mint.money(10, 'USD'),
                 money.clamp(Mint.money(0, 'USD'), 10)
  end

  def test_clamp_with_jpy
    # Subunit-0 currency must not introduce a scaling surprise.
    money = Mint.money(500, 'JPY')

    assert_equal Mint.money(100, 'JPY'), money.clamp(0, 100)
    assert_equal Mint.money(0, 'JPY'), money.clamp(0, 1000)
    assert_equal Mint.money(500, 'JPY'), money.clamp(100, 1000)
  end

  def test_clamp_with_negative_numeric_bound
    money = Mint.money(5, 'USD')

    assert_equal Mint.money(-5, 'USD'), money.clamp(-10, -5)
    assert_equal Mint.money(0, 'USD'), money.clamp(-5, 0)
  end

  def test_clamp_preserves_currency
    eur = Mint.money(50, 'EUR')
    result = eur.clamp(0, 100)

    assert_equal 'EUR', result.currency_code
  end

  def test_clamp_returns_frozen_money
    # Both the in-range self and the out-of-range return must be frozen.
    in_range = Mint.money(5, 'USD').clamp(0, 10)
    out_of_range = Mint.money(50, 'USD').clamp(0, 10)

    assert_predicate in_range, :frozen?
    assert_predicate out_of_range, :frozen?
  end

  def test_clamp_rejects_mismatched_currency
    money = Mint.money(5, 'USD')

    assert_raises(ArgumentError) do
      money.clamp(Mint.money(0, 'EUR'), Mint.money(10, 'USD'))
    end
    assert_raises(ArgumentError) do
      money.clamp(Mint.money(0, 'USD'), Mint.money(10, 'EUR'))
    end
  end

  def test_clamp_rejects_non_numeric_non_money_min
    money = Mint.money(5, 'USD')

    assert_raises(ArgumentError) { money.clamp('0',    Mint.money(10, 'USD')) }
    assert_raises(ArgumentError) { money.clamp(nil,    Mint.money(10, 'USD')) }
    assert_raises(ArgumentError) { money.clamp(Object.new, Mint.money(10, 'USD')) }
  end

  def test_clamp_rejects_non_numeric_non_money_max
    money = Mint.money(5, 'USD')

    assert_raises(ArgumentError) { money.clamp(Mint.money(0, 'USD'), '10') }
    assert_raises(ArgumentError) { money.clamp(Mint.money(0, 'USD'), nil) }
    assert_raises(ArgumentError) { money.clamp(Mint.money(0, 'USD'), Object.new) }
  end
end

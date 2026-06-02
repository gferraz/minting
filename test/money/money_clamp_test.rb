class MoneyClampTest < Minitest::Test
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

# frozen_string_literal: true

using Mint

class MoneyClampTest < Minitest::Test
  def test_clamp_in_range_returns_self
    money = 5.dollars

    assert_equal money, money.clamp(0.dollars, 10.dollars)
    assert_same money, money.clamp(0, 10)
  end

  def test_clamp_below_min_returns_min
    money = -5.dollars

    assert_equal 0.dollars, money.clamp(0.dollars, 10.dollars)
    assert_equal 0.dollars, money.clamp(0, 10)
  end

  def test_clamp_above_max_returns_max
    money = 50.dollars

    assert_equal 10.dollars, money.clamp(0.dollars, 10.dollars)
    assert_equal 10.dollars, money.clamp(0, 10)
  end

  def test_clamp_at_boundary_returns_self
    # Clamp at the lower bound is in-range, so the receiver is returned.
    at_min = 0.dollars

    assert_same at_min, at_min.clamp(0, 10)

    # Clamp at the upper bound is also in-range.
    at_max = 10.dollars

    assert_same at_max, at_max.clamp(0, 10)
  end

  def test_clamp_accepts_money_bounds
    money = 5.dollars

    assert_equal money, money.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_accepts_numeric_bounds
    # The common "price.clamp(0, 100)" idiom: Numeric is interpreted
    # as an amount in self's currency.
    money = Mint.money(500, 'USD')

    assert_equal Mint.money(100, 'USD'), money.clamp(0, 100)
  end

  def test_clamp_mixed_bound_types
    # One bound is Money, the other is Numeric. Both should work.
    money = 50.dollars

    assert_equal 10.dollars,
                 money.clamp(0, 10.dollars)
    assert_equal 10.dollars,
                 money.clamp(0.dollars, 10)
  end

  def test_clamp_with_jpy
    # Subunit-0 currency must not introduce a scaling surprise.
    money = Mint.money(500, 'JPY')

    assert_equal Mint.money(100, 'JPY'), money.clamp(0, 100)
    assert_equal Mint.money(0, 'JPY'), (-money).clamp(0, 1000)
    assert_equal Mint.money(500, 'JPY'), money.clamp(100, 1000)
  end

  def test_clamp_with_negative_numeric_bound
    money = 5.dollars

    assert_equal(-5.dollars, money.clamp(-10, -5))
    assert_equal 0.dollars, money.clamp(-5, 0)
  end

  def test_clamp_with_nil_bound
    money = 5.dollars

    assert_equal 5.dollars, money.clamp(nil, nil)
    assert_equal Mint.money(4, 'USD'), money.clamp(nil, 4)
    assert_equal 5.dollars, money.clamp(0, nil)
  end

  def test_clamp_with_range_bound
    money = 5.dollars

    assert_equal(-5.dollars, money.clamp(-10..-5))
    assert_equal 0.dollars, money.clamp(-5..0)
  end

  def test_clamp_preserves_currency
    eur = Mint.money(50, 'EUR')
    result = eur.clamp(0, 100)

    assert_equal 'EUR', result.currency_code
  end

  def test_clamp_rejects_mismatched_currency
    money = 5.dollars

    assert_raises(ArgumentError) do
      money.clamp(Mint.money(0, 'EUR'), 10.dollars)
    end
    assert_raises(ArgumentError) do
      money.clamp(0.dollars, Mint.money(10, 'EUR'))
    end
  end

  def test_clamp_rejects_invalid_min_argument
    money = 5.dollars

    assert_raises(ArgumentError) { money.clamp('0', 10.dollars) }
    assert_raises(ArgumentError) { money.clamp(Object.new, 10.dollars) }
  end

  def test_clamp_rejects_invalid_max_argument
    money = 5.dollars

    assert_raises(ArgumentError) { money.clamp(0..10, 12) }
    assert_raises(ArgumentError) { money.clamp(0.dollars, '10') }
    assert_raises(ArgumentError) { money.clamp(0.dollars, Object.new) }
  end
end

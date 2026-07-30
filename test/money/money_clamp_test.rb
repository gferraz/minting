# frozen_string_literal: true

class MoneyClampTest < Minitest::Test
  def test_clamp_in_range_returns_self
    money = 5.dollars

    assert_equal money, money.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_below_min_returns_min
    money = -5.dollars

    assert_equal 0.dollars, money.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_above_max_returns_max
    money = 50.dollars

    assert_equal 10.dollars, money.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_at_boundary_returns_self
    at_min = 0.dollars
    assert_same at_min, at_min.clamp(0.dollars, 10.dollars)

    at_max = 10.dollars
    assert_same at_max, at_max.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_accepts_money_bounds
    money = 5.dollars

    assert_equal money, money.clamp(0.dollars, 10.dollars)
  end

  def test_clamp_with_nil_bound
    money = 5.dollars

    assert_equal 5.dollars, money.clamp(nil, nil)
  end

  def test_clamp_rejects_mismatched_currency
    money = 5.dollars

    assert_raises(ArgumentError) do
      money.clamp(Money.from(0, 'EUR'), 10.dollars)
    end
    assert_raises(ArgumentError) do
      money.clamp(0.dollars, Money.from(10, 'EUR'))
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

class MoneyTest < Minitest::Test

  def test_its_contructors
    assert_instance_of Money, Money.new(100r, Currency[:USD])
    assert_instance_of Money, Money.new(1r, Currency[:USD])
    assert_instance_of Money, Money.new(14r, Currency[:PEN])

    assert_raises(ArgumentError) { Money.new('b', Currency[:USD]) }
    assert_raises(ArgumentError) { Money.new(10r, Object.new) }
  end

  def test_equality
    ten_dollars = Money.new(10r, Currency[:USD])

    assert_equal ten_dollars, Money.new(10r, Currency[:USD])
    refute_equal ten_dollars, Money.new(11r, Currency[:USD])
    refute_equal ten_dollars, Money.new(10r, Currency[:JPY])
  end

  def test_rounded_equality
    ten_dollars = Money.new(10r, Currency[:USD])

    assert_equal ten_dollars, Money.new(10.001.to_r, Currency[:USD])
    assert_equal ten_dollars, Money.new(9.999.to_r, Currency[:USD])
    refute_equal ten_dollars, Money.new(9.995.to_r, Currency[:USD])
    refute_equal ten_dollars, Money.new(10.009.to_r, Currency[:USD])
  end

  def test_zero
    zero_dollars = Money.new(0r, Currency[:USD])
    zero_soles = Money.new(0r, Currency[:PEN])

    assert zero_dollars.zero?
    assert_equal zero_dollars, zero_soles
    assert_equal 0, zero_dollars
    assert_equal zero_dollars, 0
    refute Money.new(100r, Currency[:USD]).zero?
  end
end

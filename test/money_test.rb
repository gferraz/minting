class MoneyTest < Minitest::Test
  def setup
    @usd = Currency.register(:USD, subunit: 2, symbol: '$')
    @pen = Currency.register(:PEN, subunit: 2, symbol: 'S/.')
    @brl = Currency.register(:BRL, subunit: 2, symbol: 'R$')
  end

  def test_its_contructors
    assert_instance_of Money, Money.new(100r, @usd)
    assert_instance_of Money, Money.new(1r, Currency[:USD])
    assert_instance_of Money, Money.new(14r, @pen)

    assert_raises(ArgumentError) { Money.new('b', @usd) }
    assert_raises(ArgumentError) { Money.new(10r, Object.new) }
  end

  def test_equality
    ten_dollars = Money.new(10r, @usd)

    assert_equal ten_dollars, Money.new(10r, @usd)
    refute_equal ten_dollars, Money.new(11r, @usd)
    refute_equal ten_dollars, Money.new(10r, @brl)
  end

  def test_rounded_equality
    ten_dollars = Money.new(10r, @usd)

    assert_equal ten_dollars, Money.new(10.001.to_r, @usd)
    assert_equal ten_dollars, Money.new(9.999.to_r, @usd)
    refute_equal ten_dollars, Money.new(9.995.to_r, @usd)
    refute_equal ten_dollars, Money.new(10.01.to_r, @usd)
  end

  def test_zero
    zero_dollars = Money.new(0r, @usd)
    zero_soles = Money.new(0r, @pen)

    assert zero_dollars.zero?
    assert_equal zero_dollars, zero_soles
    assert_equal 0, zero_dollars
    assert_equal zero_dollars, 0
    refute Money.new(100r, @usd).zero?
  end
end

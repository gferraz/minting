class MoneyTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_its_contructors
    assert_instance_of Mint::Money, Mint::Money.new(100r, USD)
    assert_instance_of Mint::Money, Mint::Money.new(1r, USD)
    assert_instance_of Mint::Money, Mint::Money.new(14r, Mint::Currency[:PEN])

    assert_raises(ArgumentError) { Mint::Money.new('b', USD) }
    assert_raises(ArgumentError) { Mint::Money.new(10r, Object.new) }
  end

  def test_equality
    ten_dollars = Mint::Money.new(10r, USD)

    assert_equal ten_dollars, Mint::Money.new(10r, USD)
    refute_equal ten_dollars, Mint::Money.new(11r, USD)
    refute_equal ten_dollars, Mint::Money.new(10r, Mint::Currency[:JPY])
  end

  def test_inspect
    assert_equal '[USD 10.34]', Mint::Money.new(10.34.to_r, USD).inspect
  end

  def test_rounded_equality
    ten_dollars = Mint::Money.new(10r, USD)

    assert_equal ten_dollars, Mint::Money.new(10.001.to_r, USD)
    assert_equal ten_dollars, Mint::Money.new(9.999.to_r, USD)
    refute_equal ten_dollars, Mint::Money.new(9.995.to_r, USD)
    refute_equal ten_dollars, Mint::Money.new(10.009.to_r, USD)
  end

  def test_zero
    zero_dollars = Mint::Money.new(0r, USD)
    zero_soles = Mint::Money.new(0r, Mint::Currency[:PEN])

    assert zero_dollars.zero?
    assert_equal zero_dollars, zero_soles
    assert_equal 0, zero_dollars
    assert_equal zero_dollars, 0
    refute Mint::Money.new(100r, USD).zero?
  end
end

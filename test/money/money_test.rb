class MoneyTest < Minitest::Test
  def usd
    @usd ||= Mint::Currency[:USD]
  end

  def test_its_contructors
    assert_instance_of Mint::Money, Mint::Money.new(100r, usd)
    assert_instance_of Mint::Money, Mint::Money.new(1r, usd)
    assert_instance_of Mint::Money, Mint::Money.new(14r, Mint::Currency[:PEN])

    assert_raises(ArgumentError) { Mint::Money.new('b', usd) }
    assert_raises(ArgumentError) { Mint::Money.new(10r, Object.new) }
  end

  def test_inspect
    assert_equal '[USD 10.34]', Mint::Money.new(10.34.to_r, usd).inspect
  end

  def test_zero
    zero_dollars = Mint::Money.new(0r, usd)
    zero_soles = Mint::Money.new(0r, Mint::Currency[:PEN])

    assert zero_dollars.zero?
    assert_equal zero_dollars, zero_soles
    assert_equal 0, zero_dollars
    assert_equal zero_dollars, 0
    refute Mint::Money.new(100r, usd).zero?
  end

  def test_nonzero
    two_dollars = Mint::Money.new(2r, usd)
    two_soles = Mint::Money.new(2r, Mint::Currency[:PEN])

    assert two_dollars.nonzero?
    refute_equal two_dollars, two_soles
    refute_equal 0, two_dollars
    refute_equal two_dollars, 0
  end
end

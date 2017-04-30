class MoneyTest < Minitest::Test
  def usd
    @usd ||= Mint::Currency[:USD]
  end

  def test_equality
    ten_dollars = Mint::Money.new(10r, usd)

    assert_equal ten_dollars, Mint::Money.new(10r, usd)
    refute_equal ten_dollars, Mint::Money.new(11r, usd)
    refute_equal ten_dollars, Mint::Money.new(10r, Mint::Currency[:JPY])
  end

  def test_inequality
    ten_dollars = Mint::Money.new(10r, usd)
    two_dollars = Mint::Money.new(2r, usd)

    refute_equal ten_dollars, two_dollars

    assert ten_dollars > two_dollars
    assert two_dollars <= ten_dollars

    refute ten_dollars <= two_dollars
    refute two_dollars > ten_dollars

    assert ten_dollars > 0
    assert 0 < ten_dollars

    assert_raises(TypeError) { ten_dollars > 1 }
    assert_raises(TypeError) { ten_dollars < 100 }
  end
end

class MoneyComparableTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_equality
    ten_dollars = Mint::Money.new(10r, USD)

    assert_equal ten_dollars, Mint::Money.new(10r, USD)
    refute_equal ten_dollars, Mint::Money.new(11r, USD)
    refute_equal ten_dollars, Mint::Money.new(10r, Mint::Currency[:JPY])
  end

  def test_inequality
    ten_dollars = Mint::Money.new(10r, USD)
    two_dollars = Mint::Money.new(2r, USD)

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

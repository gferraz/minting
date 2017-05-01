class MoneyArithmeticsTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_addition
    two_dollars = Mint::Money.new(2r, USD)
    six_dollars = Mint::Money.new(6r, USD)
    ten_dollars = Mint::Money.new(10r, USD)

    assert_equal ten_dollars, two_dollars + two_dollars + six_dollars
    assert_equal ten_dollars, ten_dollars + 0
    assert_equal ten_dollars, 0 + ten_dollars

    assert_raises(TypeError) { ten_dollars + 0.0023 }
    assert_raises(TypeError) { 1.23 + ten_dollars }
  end
end

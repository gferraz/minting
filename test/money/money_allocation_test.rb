class MoneyAllocationTest < Minitest::Test
  def test_money_allocation
    usd = Mint.new(:USD)
    thousand = usd.money(1000)

    parts = thousand.split(3)
    assert_equal usd.money(333.34), parts[0]
    assert_equal usd.money(333.33), parts[1]
    assert_equal usd.money(333.33), parts[2]
  end
end

class MoneyAllocationTest < Minitest::Test
  def test_money_allocation
    usd = Mint.new(:USD)
    price = usd.money(10)
    number_of_installments = 7
    installments = price.split(number_of_installments)
    assert_equal usd.money(1.42), installments[0]
    assert_equal usd.money(1.43), installments[1]
    assert_equal usd.money(1.43), installments[2]
    assert_equal usd.money(1.43), installments[3]
    assert_equal usd.money(1.43), installments[4]
    assert_equal usd.money(1.43), installments[5]
    assert_equal usd.money(1.43), installments[6]
    assert_equal number_of_installments, installments.size
    assert_equal price, installments.sum

    number_of_installments = 3
    installments = price.split(number_of_installments)
    assert_equal usd.money(3.34), installments[0]
    assert_equal usd.money(3.33), installments[1]
    assert_equal usd.money(3.33), installments[2]
    assert_equal number_of_installments, installments.size
    assert_equal price, installments.sum
  end
end

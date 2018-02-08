class MoneyAllocationTest < Minitest::Test
  def test_money_split
    usd = Mint.new(:USD)
    price = usd.money(10)
    number_of_installments = 7
    installments = price.split(number_of_installments)
    assert_equal [usd.money(1.42), usd.money(1.43), usd.money(1.43), usd.money(1.43),
                  usd.money(1.43), usd.money(1.43), usd.money(1.43)], installments

    number_of_installments = 3
    installments = price.split(number_of_installments)
    assert_equal [usd.money(3.34), usd.money(3.33), usd.money(3.33)], installments
  end

  def test_money_allocation
    usd = Mint.new(:USD)
    value = usd.money(10)
    proportions = [1, 2, 3]
    allocation = value.allocate(proportions)
    assert_equal [usd.money(1.67), usd.money(3.33), usd.money(5)], allocation
    assert_equal value, allocation.sum

    proportion = [0.333, 0.333, 0.333]
    allocation = value.allocate(proportion)
    assert_equal [usd.money(3.34), usd.money(3.33), usd.money(3.33)], allocation
    assert_equal value, allocation.sum
  end
end

class MoneyAllocationTest < Minitest::Test
  def test_money_split
    usd = Mint.new(:USD)
    price = usd.money(10)

    installments = price.split(7)
    assert_equal [usd.money(1.42), usd.money(1.43), usd.money(1.43), usd.money(1.43),
                  usd.money(1.43), usd.money(1.43), usd.money(1.43)], installments

    installments = price.split(3)
    assert_equal [usd.money(3.34), usd.money(3.33), usd.money(3.33)], installments

    installments = price.split(4)
    assert_equal [usd.money(2.50), usd.money(2.50), usd.money(2.50), usd.money(2.50)], installments
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

    proportion = [0.25, 0.25, 0.25, 0.25]
    allocation = value.allocate(proportion)
    assert_equal [usd.money(2.50), usd.money(2.50), usd.money(2.50), usd.money(2.50)], allocation
    assert_equal value, allocation.sum
  end
end

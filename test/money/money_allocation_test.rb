class MoneyAllocationTest < Minitest::Test
  def test_money_split
    price = Mint.money(10, 'USD')

    usd143 = Mint.money(1.43, 'USD')
    usd250 = Mint.money(2.50, 'USD')

    installments = price.split(7)
    assert_equal [Mint.money(1.42, 'USD'), usd143, usd143, usd143, usd143, usd143, usd143], installments

    installments = price.split(3)
    assert_equal [Mint.money(3.34, 'USD'), Mint.money(3.33, 'USD'), Mint.money(3.33, 'USD')], installments

    installments = price.split(4)
    assert_equal [usd250, usd250, usd250, usd250], installments
  end

  def test_money_allocation
    value = Mint.money(10, 'USD')
    proportions = [1, 2, 3]
    allocation = value.allocate(proportions)
    assert_equal [Mint.money(1.67, 'USD'), Mint.money(3.33, 'USD'), Mint.money(5, 'USD')], allocation
    assert_equal value, allocation.sum

    proportion = [0.333, 0.333, 0.333]
    allocation = value.allocate(proportion)
    assert_equal [Mint.money(3.34, 'USD'), Mint.money(3.33, 'USD'), Mint.money(3.33, 'USD')], allocation
    assert_equal value, allocation.sum

    proportion = [0.25, 0.25, 0.25, 0.25]
    allocation = value.allocate(proportion)
    assert_equal [Mint.money(2.50, 'USD'), Mint.money(2.50, 'USD'), Mint.money(2.50, 'USD'), Mint.money(2.50, 'USD')],
                 allocation
    assert_equal value, allocation.sum
  end
end

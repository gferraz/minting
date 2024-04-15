class MoneyAllocationTest < Minitest::Test
  def test_money_split
    price = Mint.money(10, 'USD')

    installments = price.split(7)
    assert_equal 7, installments.size
    assert_equal price, installments.sum

    installments = price.split(3)
    assert_equal 3, installments.size
    assert_equal price, installments.sum

    installments = price.split(4)
    assert_equal 4, installments.size
    assert_equal price, installments.sum

    five = Mint.money(5, 'USD')
    installments = five.split(3)
    assert_equal 3, installments.size
    assert_equal five, installments.sum
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

    proportion = [0.333, 0.333, 0.333]
    five = Mint.money(5, 'USD')
    allocation = five.allocate(proportion)
    assert_equal 3, allocation.size
    assert_equal five, allocation.sum
  end
end

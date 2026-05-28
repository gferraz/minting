using Mint

class MoneyAllocationTest < Minitest::Test
  def test_money_allocate_errors
    price = 10.10.dollars
    assert_raises(ArgumentError) { price.allocate([]) }
    assert_raises(ArgumentError) { price.allocate([0, 0, 0]) }
    assert_raises(ArgumentError) { price.split(0) }
    assert_raises(ArgumentError) { price.split(-1) }
    assert_raises(ArgumentError) { price.split(1.5) }
    assert_raises(TypeError) { price.allocate([1, '2']) }
  end

  def test_allocate_does_not_mutate_proportions
    price = 10.dollars
    proportions = [1, 2, 3]
    original = proportions.dup

    price.allocate(proportions)

    assert_equal original, proportions
  end

  def test_money_split
    price = 10.10.dollars

    installments = price.split(7)

    assert_equal 7, installments.size
    assert_equal 2, installments.count(1.45.dollars)
    assert_equal price, installments.sum

    installments = price.split(3)

    assert_equal 3, installments.size
    assert_equal 1, installments.count(3.36.dollars)
    assert_equal price, installments.sum

    installments = price.split(4)

    assert_equal 4, installments.size
    assert_equal 2, installments.count(2.52.dollars)
    assert_equal price, installments.sum

    five = Mint.money(5, 'USD')
    installments = five.split(3)

    assert_equal 1.66.dollars, installments[0]
    assert_equal 3, installments.size
    assert_equal five, installments.sum
  end

  def test_split_negative_money
    debt = Mint.money(-10, 'USD')

    installments = debt.split(3)

    assert_equal [-3.34.dollars, -3.33.dollars, -3.33.dollars], installments
    assert_equal debt, installments.sum
  end

  def test_split_zero_subunit_currency
    price = Mint.money(10, 'JPY')

    installments = price.split(3)

    assert_equal [Mint.money(4, 'JPY'), Mint.money(3, 'JPY'), Mint.money(3, 'JPY')],
                 installments
    assert_equal price, installments.sum
  end

  def test_money_allocation
    value = Mint.money(10.0, 'USD')
    proportions = [1, 2, 3]
    allocation = value.allocate(proportions)

    assert_equal [1.67.dollars, 3.33.dollars, 5.dollars], allocation
    assert_equal value, allocation.sum

    proportion = [0.333, 0.333, 0.333]
    allocation = value.allocate(proportion)

    assert_equal [3.34.dollars, 3.33.dollars, 3.33.dollars], allocation
    assert_equal value, allocation.sum

    proportion = [0.25, 0.25, 0.25, 0.25]
    allocation = value.allocate(proportion)

    assert_equal [2.50.dollars, 2.50.dollars,
                  2.50.dollars, 2.50.dollars], allocation
    assert_equal value, allocation.sum

    proportion = [0.333, 0.333, 0.333]
    five = Mint.money(5.0, 'USD')
    allocation = five.allocate(proportion)

    assert_equal 3, allocation.size
    assert_equal five, allocation.sum
  end

  def test_allocate_negative_money
    debt = Mint.money(-10, 'USD')

    allocation = debt.allocate([1, 2, 3])

    assert_equal [-1.67.dollars, -3.33.dollars, -5.dollars], allocation
    assert_equal debt, allocation.sum
  end

  def test_allocate_with_negative_proportions
    price = 10.dollars

    allocation = price.allocate([-1, 2])

    assert_equal [-10.dollars, 20.dollars], allocation
    assert_equal price, allocation.sum
  end

  def test_allocate_conserves_awkward_remainders
    price = Mint.money(0.05, 'USD')

    allocation = price.allocate([1, 1, 1, 1])

    assert_equal [0.02.dollars, 0.01.dollars, 0.01.dollars, 0.01.dollars],
                 allocation
    assert_equal price, allocation.sum
  end
end

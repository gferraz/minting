using Mint

class MoneyArithmeticsTest < Minitest::Test
  def test_addition
    assert_equal 10.dollars, 2.dollars + 2.dollars + 6.dollars
    assert_equal 10.dollars, 0.dollars + 10.dollars
    assert_equal 10.dollars, 0 + 10.dollars + 0

    assert_raises(TypeError) { 10.dollars + 0.0023 }
    assert_raises(TypeError) { 1.23 + 10.dollars }
    assert_raises(TypeError) { 10.dollars + 0.reais }
    assert_raises(TypeError) { 0.reais + 10.dollars }
  end

  def test_subtraction
    assert_equal 6.dollars, 10.dollars - 2.dollars - 2.dollars
    assert_equal(-10.dollars, -10.dollars)
    assert_equal(-10.dollars, 0 - 10.dollars)
    assert_equal(10.dollars, 10.dollars - 0)

    assert_raises(TypeError) { 10.dollars - 0.0023 }
    assert_raises(TypeError) { 10.dollars - 0.0023 }
    assert_raises(TypeError) { 0.reais - 10.dollars }
  end

  def test_multiplication
    assert_equal 10.dollars, 5.0001 * 2.dollars
    assert_equal 6.dollars, 2.dollars * 3

    assert_equal 2.dollars, 10.dollars * 0.2

    assert_equal 10.dollars, 10.dollars * 1
    assert_equal 10.dollars, 1 * 10.dollars

    assert_raises(TypeError) { 10.dollars * 0.dollars }
  end

  def test_multiplication_negatives
    assert_equal(-10.dollars, 10.dollars * -1)
    assert_equal(-10.dollars, -1 * 10.dollars)
    assert_equal(-6.dollars, -2.dollars * 3)
    assert_equal(-6.dollars, -3 * 2.dollars)
  end

  def test_multiplication_exceptions
    assert_raises(TypeError) { 10.dollars * 2.dollars }
    assert_raises(TypeError) { 10.dollars * Object.new }
  end

  def test_division
    assert_equal 2.dollars, 10.dollars / 5
    assert_equal 2.dollars, 6.dollars / 3

    assert_equal 5, 10.dollars / 2.dollars
    assert_equal 3, 6.dollars / 2.dollars

    assert_raises(TypeError) { 10.dollars / '2' }
    assert_raises(TypeError) { 2 / 10.dollars }
    assert_raises(TypeError) { 0 / 10.dollars }
    assert_raises(ZeroDivisionError) { 10.dollars / 0 }
  end

  def test_abs
    assert_equal 10.dollars, 10.dollars.abs
    assert_equal 10.dollars, -10.dollars.abs
    assert_equal 2.dollars, -2.dollars.abs
    assert_equal 6.dollars, (-3 * 2.dollars).abs
  end

  def test_sign
    assert_predicate 10.dollars, :positive?
    refute_predicate 10.dollars, :negative?
    assert_predicate(-10.dollars, :negative?)
    refute_predicate(-10.dollars, :positive?)
  end
end

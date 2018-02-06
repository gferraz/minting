class MoneyArithmeticsTest < Minitest::Test
  USD = Mint::Currency[:USD]
  BRL = Mint::Currency[:BRL]

  def setup
    @zero = Mint::Money.new(0r, USD)
    @zero_brl = Mint::Money.new(0r, BRL)
    @two = Mint::Money.new(2r, USD)
    @six = Mint::Money.new(6r, USD)
    @ten = Mint::Money.new(10r, USD)
    @negative_ten = Mint::Money.new(-10r, USD)
  end

  def test_addition
    assert_equal @ten, @two + @two + @six
    assert_equal @ten, @ten + 0
    assert_equal @ten, 0 + @ten
    assert_equal @ten, @zero + @ten
    assert_equal @ten, @zero_brl + @ten

    assert_raises(TypeError) { @ten + 0.0023 }
    assert_raises(TypeError) { 1.23 + @ten }
  end

  def test_subtraction
    assert_equal @six, @ten - @two - @two
    assert_equal @ten, @ten - 0
    assert_equal @negative_ten, 0 - @ten
    assert_equal(@negative_ten, @zero - @ten)
    assert_equal(@negative_ten, @zero_brl - @ten)
    assert_equal(@negative_ten, -@ten)

    assert_raises(TypeError) { @ten - 0.0023 }
    assert_raises(TypeError) { 1.23 - @ten }
  end

  def test_multiplication
    assert_equal @ten, 5.0001 * @two
    assert_equal @six, @two * 3

    assert_equal @two, @ten * 0.2
    assert_equal @zero, @ten * @zero

    assert_equal @ten, @ten * 1
    assert_equal @ten, 1 * @ten
  end

  def test_multiplication_negatives
    assert_equal(-@ten, @ten * -1)
    assert_equal(-@ten, -1 * @ten)
    assert_equal(-@six, -@two * 3)
    assert_equal(-@six, -3 * @two)
  end

  def test_multiplication_exceptions
    assert_raises(TypeError) { @ten * @two }
    assert_raises(TypeError) { @ten * Object.new }
  end

  def test_division
    assert_equal @two, @ten / 5
    assert_equal @two, @six / 3
    assert_equal @two, 12 / @six

    assert_equal 5, @ten / @two
    assert_equal 3, @six / @two

    assert_raises(TypeError) { @ten / '2' }
    assert_raises(ZeroDivisionError) { @ten / 0 }
  end

  def test_abs
    assert_equal @ten, @ten.abs
    assert_equal @ten, (-@ten).abs
    assert_equal @two, (-@two).abs
    assert_equal @six, (-3 * @two).abs
  end
end

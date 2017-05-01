class MoneyArithmeticsTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def setup
    @zero = Mint::Money.new(0r, USD)
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

    assert_raises(TypeError) { @ten + 0.0023 }
    assert_raises(TypeError) { 1.23 + @ten }
  end

  def test_subtraction
    assert_equal @six, @ten - @two - @two
    assert_equal @ten, @ten - 0
    assert_equal(@negative_ten, 0 - @ten)
    assert_equal(@negative_ten, -@ten)

    assert_raises(TypeError) { @ten - 0.0023 }
    assert_raises(TypeError) { 1.23 - @ten }
  end

  def test_multiplication
    assert_equal Mint::Money.new(20r, USD), 2.0001 * @ten
    assert_equal Mint::Money.new(16r, USD), @two * 8

    assert_equal @two, @ten * 0.2
    assert_equal @zero, @ten * @zero

    assert_equal @ten, @ten * 1
    assert_equal @ten, 1 * @ten

    assert_equal(-@ten, @ten * -1)
    assert_equal(-@ten, -1 * @ten)

    assert_raises(TypeError) { @ten * @two }
    assert_raises(TypeError) { @ten * Object.new }
  end
end

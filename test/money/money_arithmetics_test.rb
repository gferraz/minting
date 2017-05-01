class MoneyArithmeticsTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_addition
    two = Mint::Money.new(2r, USD)
    six = Mint::Money.new(6r, USD)
    ten = Mint::Money.new(10r, USD)

    assert_equal ten, two + two + six
    assert_equal ten, ten + 0
    assert_equal ten, 0 + ten

    assert_raises(TypeError) { ten + 0.0023 }
    assert_raises(TypeError) { 1.23 + ten }
  end

  def test_subtraction
    two = Mint::Money.new(2r, USD)
    six = Mint::Money.new(6r, USD)
    ten = Mint::Money.new(10r, USD)
    negative_ten = Mint::Money.new(-10r, USD)

    assert_equal six, ten - two - two
    assert_equal ten, ten - 0
    assert_equal(negative_ten, 0 - ten)

    assert_raises(TypeError) { ten - 0.0023 }
    assert_raises(TypeError) { 1.23 - ten }
  end
end

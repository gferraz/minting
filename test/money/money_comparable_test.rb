class MoneyComparableTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def setup
    @ten = Mint::Money.new(10r, USD)
    @two = Mint::Money.new(2r, USD)
  end

  def test_equality
    assert_equal @ten, Mint::Money.new(10r, USD)
    refute_equal @ten, Mint::Money.new(11r, USD)
    refute_equal @ten, Object.new
    refute_equal @ten, 10
    refute_equal @ten, Mint::Money.new(10r, Mint::Currency[:JPY])
    refute_equal @ten, @two
  end

  def test_inequality
    assert @ten > @two
    assert @two <= @ten

    refute @ten <= @two
    refute @two > @ten

    assert @ten > 0
    assert 0 < @ten
  end

  def test_inequality_exceptions
    assert_raises(TypeError) { @ten > 1 }
    assert_raises(TypeError) { @ten < 100 }
    assert_raises(TypeError) { @ten <= Object.new }
  end
end

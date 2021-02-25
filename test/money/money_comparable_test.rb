class MoneyComparableTest < Minitest::Test
  USD = Mint::Currency[:USD]
  BRL = Mint::Currency[:BRL]

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

  def test_equal
    ten_usd = Mint::Money.new(10r, USD)

    assert       @ten.eql? ten_usd
    assert_equal @ten.hash, ten_usd.hash
    refute       @ten.equal? ten_usd

    assert_equal Mint::Money.new(0r, USD).hash, Mint::Money.new(0r, BRL).hash
  end

  def test_inequality
    assert @ten > @two
    assert @two <= @ten

    refute @ten <= @two
    refute @two > @ten

    assert @ten.positive?
    assert @ten.positive?
  end

  def test_inequality_exceptions
    assert_raises(TypeError) { @ten > 1 }
    assert_raises(TypeError) { @ten < 100 }
    assert_raises(TypeError) { @ten <= Object.new }
  end
end

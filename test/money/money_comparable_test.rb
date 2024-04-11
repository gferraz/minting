class MoneyComparableTest < Minitest::Test

  def setup
    @ten = Mint.money(10r, 'USD')
    @two = Mint.money(2r, 'USD')
  end

  def test_equality
    assert_equal @ten, Mint.money(10r, 'USD')
    refute_equal @ten, Mint.money(11r, 'USD')
    refute_equal @ten, Object.new
    refute_equal @ten, 10
    refute_equal @ten, Mint.money(10r, 'JPY')
    refute_equal @ten, @two
  end

  def test_equal
    ten_usd = Mint.money(10r, 'USD')

    assert       @ten.eql? ten_usd
    assert_equal @ten.hash, ten_usd.hash
    refute       @ten.equal? ten_usd

    assert_equal Mint.money(0r, 'USD').hash, Mint.money(0r, 'BRL').hash
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

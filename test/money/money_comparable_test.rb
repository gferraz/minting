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
    refute_same @ten, ten_usd

    assert_equal Mint.money(0r, 'USD').hash, Mint.money(0r, 'BRL').hash
  end

  def test_inequality
    assert_operator @ten, :>, @two
    assert_operator @two, :<=, @ten

    refute_operator @ten, :<=, @two
    refute_operator @two, :>, @ten

    assert_predicate @ten, :positive?
    assert_predicate @ten, :positive?
  end

  def test_inequality_exceptions
    assert_raises(TypeError) { @ten > 1 }
    assert_raises(TypeError) { @ten < 100 }
    assert_raises(TypeError) { @ten <= Object.new }
  end

  def test_case_operator
    assert_raises(TypeError) { Mint.money(1, 'BRL') <=> @two }
    assert_raises(TypeError) { 2 <=> @two }
    assert_equal(-1, @two <=> @ten)
    assert_equal 0, @ten <=> Mint.money(10, 'USD')
    assert_equal 1, @ten <=> @two
    assert_equal 1, Mint.money(2, 'BRL') <=> 0
    assert_equal(-1, 0 <=> Mint.money(2, 'BRL'))
  end
end

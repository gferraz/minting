using Mint

class MoneyComparableTest < Minitest::Test
  def test_equality
    assert_equal 10.dollars, Mint.money(10r, 'USD')
    refute_equal 10.dollars, Mint.money(11r, 'USD')
    refute_equal 10.dollars, Object.new
    refute_equal 10.dollars, 10
    refute_equal 10.dollars, Mint.money(10r, 'JPY')
    refute_equal 10.dollars, 2.dollars
  end

  def test_equal
    ten_usd = Mint.money(10r, 'USD')

    assert       10.dollars.eql? ten_usd
    assert_equal 10.dollars.hash, ten_usd.hash
    refute_same 10.dollars, ten_usd

    assert_equal Mint.money(0r, 'USD').hash, Mint.money(0r, 'BRL').hash
  end

  def test_inequality
    assert_operator 10.dollars, :>, 2.dollars
    assert_operator 2.dollars, :<=, 10.dollars

    refute_operator 10.dollars, :<=, 2.dollars
    refute_operator 2.dollars, :>, 10.dollars

    assert_predicate 10.dollars, :positive?
    assert_predicate 10.dollars, :positive?
  end

  def test_inequality_exceptions
    assert_raises(TypeError) { 10.dollars > 1 }
    assert_raises(TypeError) { 10.dollars < 100 }
    assert_raises(TypeError) { 10.dollars <= Object.new }
  end

  def test_case_operator
    assert_raises(TypeError) { Mint.money(1, 'BRL') <=> 2.dollars }
    assert_raises(TypeError) { 2 <=> 2.dollars }
    assert_equal(-1, 2.dollars <=> 10.dollars)
    assert_equal 0, 10.dollars <=> Mint.money(10, 'USD')
    assert_equal 1, 10.dollars <=> 2.dollars
    assert_equal 1, Mint.money(2, 'BRL') <=> 0
    assert_equal(-1, 0 <=> Mint.money(2, 'BRL'))
    refute nil <=> 4.dollars
    refute Object.new <=> 4.dollars
  end
end

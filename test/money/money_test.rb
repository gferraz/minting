using Mint

class MoneyTest < Minitest::Test
  def test_its_contructors
    assert_instance_of Mint::Money, Mint.money(100, 'USD')

    assert_raises(ArgumentError) { Mint.money('b', 'USD') }
    assert_raises(ArgumentError) { Mint.money(10r, Object.new) }
  end

  def test_amount
    assert_equal 100, Mint.money(100, 'USD').amount
    assert_equal 1,   Mint.money(1, 'USD').amount
    assert_equal 14,  Mint.money(14, Mint.currency('PEN')).amount
  end

  def test_inspect
    assert_equal '[USD 10.34]', Mint.money(10.34, 'USD').inspect
  end

  def test_same_currency
    assert Mint.money(10.34, 'USD').same_currency?(Mint.money(100, 'USD'))
    refute Mint.money(10.34, 'USD').same_currency?(30)
    refute Mint.money(10.34, 'USD').same_currency?(Mint.money(10.34, 'BRL'))
  end

  def test_zero
    zero_soles = Mint.money(0r, Mint.currency('PEN'))

    assert_predicate 0.dollars, :zero?
    assert_equal 0.dollars, zero_soles
    assert_equal 0, 0.dollars
    assert_equal 0, 0.dollars
    refute_predicate Mint.money(100r, 'USD'), :zero?
  end

  def test_nonzero
    two_soles = Mint.money(2, Mint.currency('PEN'))

    assert_predicate 2.dollars, :nonzero?
    refute_equal 2.dollars, two_soles
    refute_equal 0, 2.dollars
    refute_equal 2.dollars, 0
  end
end

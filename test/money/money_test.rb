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

  def test_zero
    zero_dollars = Mint.money(0r, 'USD')
    zero_soles = Mint.money(0r, Mint.currency('PEN'))

    assert_predicate zero_dollars, :zero?
    assert_equal zero_dollars, zero_soles
    assert_equal 0, zero_dollars
    assert_equal 0, zero_dollars
    refute_predicate Mint.money(100r, 'USD'), :zero?
  end

  def test_nonzero
    two_dollars = Mint.money(2, 'USD')
    two_soles = Mint.money(2, Mint.currency('PEN'))

    assert_predicate two_dollars, :nonzero?
    refute_equal two_dollars, two_soles
    refute_equal 0, two_dollars
    refute_equal two_dollars, 0
  end
end

class MintTest < Minitest::Test
  def test_mint_construction
    assert Mint.new('USD')
    assert Mint.new('USD').zero.zero?
    assert_raises(KeyError) { Mint.new('---') }
  end

  def test_mint_accessors
    assert_equal 'BRL', Mint.new(:BRL).currency_code
  end

  def test_inspect
    assert_equal '<Mint:PEN>', Mint.new(:PEN).inspect
  end

  def test_money_minting
    mint = Mint.new(:PEN)
    ten_reais = Mint::Money.new(10r, mint.currency)

    assert_equal Mint::Money.new(10.01.to_r, mint.currency), mint.money(10.01)

    assert_equal ten_reais, mint.money(10)
    assert_equal ten_reais, mint.money(9.999)
  end

  def test_mint_zero_amount
    dollar = Mint.new('USD')
    yen = Mint.new('JPY')

    assert_equal dollar.money(0), dollar.zero
    assert_equal yen.money(0), yen.zero
  end

  def test_mint_minimum_amount
    dollar = Mint.new('USD')
    yen = Mint.new('JPY')

    assert_equal dollar.money(0.01), dollar.minimum
    assert_equal yen.money(1),       yen.minimum
  end

  def test_mint_currency
    assert_equal Mint::Currency[:BRL], Mint.currency(:BRL)
  end
end

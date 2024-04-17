using Mint

class MintTest < Minitest::Test
  def test_money_minting
    ten_reais = Mint.money(10, 'BRL')

    assert_equal Mint.money(10.01, 'PEN'), Mint.money(10.01, 'PEN')

    assert_equal ten_reais, ten_reais.mint(10)
    assert_equal ten_reais, ten_reais.mint(9.999)
  end

  def test_mint_refinements
    assert_equal 4.reais, Mint.money(4, 'BRL')
    assert_equal 4.2.dollars, Mint.money(4.2, 'USD')
  end
end

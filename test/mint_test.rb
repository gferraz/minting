using Mint

class MintTest < Minitest::Test
  def test_money_minting
    ten_reais = Mint.money(10, 'BRL')

    assert_equal Mint.money(10.01, 'PEN'), Mint.money(10.01, 'PEN')

    assert_equal ten_reais, ten_reais.mint(10)
    assert_equal ten_reais, ten_reais.mint(9.999)
  end

  def test_mint_refinements
    assert_equal 1.real, Mint.money(1, 'BRL')
    assert_equal 1.dollar, Mint.money(1, 'USD')
    assert_equal 1.euro, Mint.money(1, 'EUR')
    assert_equal 3.reais, Mint.money(3, 'BRL')
    assert_equal 4.2.dollars, Mint.money(4.2, 'USD')
    assert_equal 5.3.euros, Mint.money(5.3, 'EUR')
    assert_equal 5.3.to_money(:EUR), Mint.money(5.3, 'EUR')
    assert_equal 5.3.mint(:EUR), Mint.money(5.3, 'EUR')
  end
end

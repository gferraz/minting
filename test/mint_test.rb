require 'test_helper'

class MintTest < Minitest::Test

  def test_mint_construction
    assert Mint.new('USD')
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

    assert_equal Money.new(10.to_r,    mint.currency), mint.money(10)
    assert_equal Money.new(10.01.to_r, mint.currency), mint.money(10.01)
    assert_equal Money.new(10.to_r,    mint.currency), mint.money(9.999)
  end
end

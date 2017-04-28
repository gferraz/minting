require 'test_helper'

class MintTest < Minitest::Test
  def test_mint_construction
    Currency.register(:USD, subunit: 2, symbol: '$')

    assert Mint.new('USD')
    assert_raises(KeyError) { Mint.new('---') }
  end

  def test_mint_accessors
    Currency.register(:BRL, subunit: 2, symbol: 'R$')

    assert_equal 'BRL', Mint.new(:BRL).currency_code
  end

  def test_inspect
    Currency.register(:USD, subunit: 2, symbol: '$')

    assert_equal '<Mint:USD>', Mint.new(:USD).inspect
  end
end

require 'test_helper'

class CurrencyTest < Minitest::Test
  def test_currency_construction
    assert Currency.register(:BRL, subunit: 2, symbol: 'R$')
    assert Currency.register(:USD, subunit: 2, symbol: '$')
    assert_raises IndexError, 'Currency: USD already exists' do
      Currency.register!(:USD, subunit: 2, symbol: '$')
    end
  end

  def test_currency_accessors
    real = Currency.register(:BRL, subunit: 2, symbol: 'R$')
    dollar = Currency.register(:USD, subunit: 2, symbol: '$')

    assert_equal ['BRL', 2, 'R$'], [real.code, real.subunit, real.symbol]
    assert_equal ['USD', 2, '$'],  [dollar.code, dollar.subunit, dollar.symbol]
  end

  def test_inspect
    currency = Currency.register(:BRL, subunit: 2, symbol: 'R$')
    assert_equal '<Currency:(BRL R$ 2)>', currency.inspect
  end

  def test_finder
    Currency.register(:BRL, subunit: 2, symbol: 'R$')

    assert_equal 'BRL', Currency[:BRL].code
  end
end

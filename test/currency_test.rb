require 'test_helper'

class CurrencyTest < Minitest::Test
  def test_currency_construction
    assert Currency.register(:HKD, subunit: 2, symbol: '$')
    assert Currency.register!(:SGD, subunit: 2, symbol: '$')
    assert_raises IndexError, 'Currency: USD already exists' do
      Currency.register!(:USD, subunit: 2, symbol: '$')
    end
  end

  def test_default_currencies
    real = Currency[:BRL]
    dollar = Currency[:USD]

    assert_equal ['BRL', 2, 'R$'], [real.code, real.subunit, real.symbol]
    assert_equal ['USD', 2, '$'],  [dollar.code, dollar.subunit, dollar.symbol]
  end

  def test_currency_accessors
    real = Currency[:BRL]
    dollar = Currency[:USD]

    assert_equal ['BRL', 2, 'R$'], [real.code, real.subunit, real.symbol]
    assert_equal ['USD', 2, '$'],  [dollar.code, dollar.subunit, dollar.symbol]
  end

  def test_inspect
    real = Currency[:BRL]
    dollar = Currency[:USD]
    assert_equal '<Currency:(BRL R$ 2)>', real.inspect
    assert_equal '<Currency:(USD $ 2)>',  dollar.inspect
  end

  def test_finder
    assert_equal 'BRL', Currency[:BRL].code
  end
end

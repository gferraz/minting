# frozen_string_literal: true

class CurrencyTest < Minitest::Test
  def setup
    @real ||= Mint.currency_for('BRL')
    @dollar ||= Mint.currency_for('USD')
    @yen ||= Mint.currency_for('JPY')
    nil
  end

  def test_currency_construction
    sgda = Mint::Currency.new(code: 'SGDA', subunit: 2, symbol: '^')

    assert_equal sgda, Mint.register_currency(code: 'SGDA', subunit: 2, symbol: '^')

    assert_raises IndexError, 'Currency: USD already exists' do
      Mint.register_currency(code: 'USD', subunit: 2, symbol: '$')
    end

    assert_raises ArgumentError, 'Currency code must be String or Symbol' do
      Mint.register_currency(code: 'USD4', subunit: 2, symbol: '$')
    end
  end

  def test_default_currencies
    assert @real
    assert @dollar
  end

  def test_currency_accessors
    assert_equal ['BRL', 2, 'R$', 630],
                 [@real.code, @real.subunit, @real.symbol, @real.priority]
    assert_equal ['USD', 2, '$', 1000],
                 [@dollar.code, @dollar.subunit, @dollar.symbol, @dollar.priority]
  end

  def test_inspect
    assert_equal '<Currency:(BRL R$ 2 Brazilian Real)>', @real.inspect
    assert_equal '<Currency:(USD $ 2 United States Dollar)>', @dollar.inspect
  end

  def test_minimum_amount
    assert_in_delta(0.01, @dollar.minimum_amount)
    assert_in_delta(0.01, @real.minimum_amount)
    assert_equal 1, @yen.minimum_amount
  end

  def test_finder
    assert_equal 'BRL', Mint.currency_for('BRL').code
  end
end

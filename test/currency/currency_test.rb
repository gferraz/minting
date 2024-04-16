class CurrencyTest < Minitest::Test
  def setup
    @real ||= Mint.currency('BRL')
    @dollar ||= Mint.currency('USD')
    @yen ||= Mint.currency('JPY')
  end

  def test_currency_construction
    assert Mint::CurrencyDirectory.register(:HKD, subunit: 2, symbol: '$')
    assert Mint::CurrencyDirectory.register!(:SGD, subunit: 2, symbol: '^')
    assert_raises IndexError, 'Currency: USD already exists' do
      Mint::CurrencyDirectory.register!('USD', subunit: 2, symbol: '$')
    end
  end

  def test_default_currencies
    assert @real
    assert @dollar
  end

  def test_currency_accessors
    assert_equal ['BRL', 2, 'R$'], [@real.code, @real.subunit, @real.symbol]
    assert_equal ['USD', 2, '$'],  [@dollar.code, @dollar.subunit, @dollar.symbol]
  end

  def test_inspect
    assert_equal '<Currency:(BRL R$ 2)>', @real.inspect
    assert_equal '<Currency:(USD $ 2)>',  @dollar.inspect
  end

  def test_minimum_amount
    assert_in_delta(0.01, @dollar.minimum_amount)
    assert_in_delta(0.01, @real.minimum_amount)
    assert_equal 1, @yen.minimum_amount
  end

  def test_finder
    assert_equal 'BRL', Mint.currency('BRL').code
  end
end

class MoneyFormatTest < Minitest::Test
  FUEL = Mint.register_currency('BRL_FUEL', subunit: 3, symbol: 'R$')

  def test_numeric_simple_format
    money = Mint.money(9.99, 'USD')

    assert_equal '$9.99',    money.to_s
    assert_equal '9',        money.to_s(format: '%<amount>d')
    assert_equal '$9.99',    money.to_s(format: '%<symbol>s%<amount>f')
    assert_equal '$+9.99',   money.to_s(format: '%<symbol>s%<amount>+f')
    assert_equal '-9.99',    (-money).to_s(format: '%<amount>f')
  end

  def test_more_numeric_simple_format
    money = Mint.money(9.99, 'USD')
    gas = Mint.money(3.457, FUEL)

    assert_equal '-9.99',    (-money).to_s(format: '%<amount>f')
    assert_equal '9.99',     money.to_s(format: '%<amount>f')
    assert_equal 'R$3.457', gas.to_s
  end

  def test_thousand_delimiter_format
    money = Mint.money(123_456_789.01, 'USD')

    assert_equal '123,456,789.01', money.to_s(format: '%<amount>f', delimiter: ',')
    assert_equal '-123,456,789.01', (-money).to_s(format: '%<amount>f', delimiter: ',')
  end

  def test_decimal_separator_format
    money = Mint.money(123_456_789.01, 'USD')

    assert_equal '123-456-789|01', money.to_s(format: '%<amount>f', delimiter: '-', separator: '|')
    assert_equal '-123456789,01', (-money).to_s(format: '%<amount>f', separator: ',')
  end

  def test_numeric_padding_format
    usd = Mint.money(9.99, 'USD')
    brl = Mint.money(12.34, 'BRL')

    assert_equal 'xx      9',
                 usd.to_s(format: 'xx%<amount>7d')
    assert_equal '        9.99 USD',
                 usd.to_s(format: '  %<amount>10f %<currency>s')
    assert_equal 'R$    +12.34',
                 brl.to_s(format: '%<symbol>2s%<amount>+10f')
    assert_equal '       -9.99',
                 (-usd).to_s(format: '  %<amount>10f')
  end

  def test_numeric_json_format
    brl = Mint.money(10, 'BRL')
    jpy = Mint.money(15, 'JPY')
    gas = Mint.money(3.457, FUEL)

    assert_equal '{"currency": "BRL", "amount": "10.00"}', brl.to_json
    assert_equal '{"currency": "JPY", "amount": "15"}', jpy.to_json
    assert_equal '{"currency": "BRL_FUEL", "amount": "3.457"}', gas.to_json
  end

  def test_numeric_html_format
    brl = Mint.money(10.05, 'BRL')
    jpy = Mint.money(15_000, 'JPY')
    gas = Mint.money(3.457, FUEL)

    assert_equal "<data class='money' title='BRL 10.05'>R$10.05</data>",
                 brl.to_html
    assert_equal "<data class='money' title='JPY 15000'>¥15000</data>",
                 jpy.to_html
    assert_equal "<data class='money' title='BRL_FUEL 3.457'>R$ +3.457</data>",
                 gas.to_html('%<symbol>2s %<amount>+f')
  end
end

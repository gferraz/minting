class MoneyFormatTest < Minitest::Test
  USD = Mint::Currency[:USD]
  BRL = Mint::Currency[:BRL]

  def test_numeric_simple_format
    money = Mint::Money.new(999 / 100r, USD)

    assert_equal '$9.99',    money.to_s
    assert_equal '9',        money.to_s(format: '%<amount>d')
    assert_equal '$9.99',    money.to_s(format: '%<symbol>s%<amount>f')
    assert_equal '$+9.99',   money.to_s(format: '%<symbol>s%<amount>+f')
    assert_equal '-9.99',    (-money).to_s(format: '%<amount>f')
  end

  def test_numeric_padding_format
    usd = Mint::Money.new(999 / 100r, USD)
    brl = Mint::Money.new(1234 / 100r, BRL)

    assert_equal 'xx      9',        usd.to_s(format: 'xx%<amount>7d')
    assert_equal '        9.99 USD', usd.to_s(format: '  %<amount>10f %<currency>s')
    assert_equal 'R$    +12.34',     brl.to_s(format: '%<symbol>2s%<amount>+10f')
    assert_equal '       -9.99',     (-usd).to_s(format: '  %<amount>10f')
  end

  def test_numeric_json_format
    brl = Mint.new(:BRL).money(10)

    assert_equal 'R$10.00', brl.to_json
  end
end

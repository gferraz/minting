class CurrencyFormatTest < Minitest::Test
  USD = Mint::Currency[:USD]
  BRL = Mint::Currency[:BRL]

  def test_numeric_simple_format
    money = Mint::Money.new(999 / 100r, USD)

    assert_equal '$9.99',    USD.format(money)
    assert_equal '9',        USD.format(money, format: '%<amount>d')
    assert_equal '$9.99',    USD.format(money, format: '%<symbol>s%<amount>f')
    assert_equal '$+9.99',   USD.format(money, format: '%<symbol>s%<amount>+f')
    assert_equal '-9.99',    USD.format(-money, format: '%<amount>f')
  end

  def test_numeric_padding_format
    assert_equal '--      1',        USD.format(1.23,  format: '--%<amount>7d')
    assert_equal ' $      4.56',     USD.format(4.56,  format: '%<symbol>2s%<amount>10f')
    assert_equal '        7.89',     USD.format(7.89,  format: '  %<amount>10f')
    assert_equal '        9.10 USD', USD.format(9.10,  format: '  %<amount>10f %<currency>s')
    assert_equal 'R$    +11.12',     BRL.format(11.12, format: '%<symbol>2s%<amount>+10f')
    assert_equal ' $    -13.14',     USD.format(-13.14, format: '%<symbol>2s%<amount>10f')
  end

  def test_canonical_format
    assert_equal 'USD 9.99',  USD.format(9.99, format: USD.canonical_format)
  end
end

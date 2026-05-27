using Mint

class MoneyParseTest < Minitest::Test
  def test_parse_with_explicit_currency
    assert_equal Mint.money(19.99, 'USD'), Mint::Money.parse('19.99', 'USD')
    assert_equal Mint.money(1234.56, 'EUR'), Mint::Money.parse('1.234,56', 'EUR')
    assert_equal Mint.money(-1010.5, 'BRL'), Mint::Money.parse('-1.010,50', 'BRL')
    assert_equal Mint.money(-1_123_010.5, 'BRL'), Mint::Money.parse('-1,123,010.50', 'BRL')
  end

  def test_parse_with_symbol
    assert_equal Mint.money(19.99, 'USD'), Mint::Money.parse('$19.99')
    assert_equal Mint.money(-19.99, 'USD'), Mint::Money.parse('-19.99 $')
    assert_equal Mint.money(12.34, 'EUR'), Mint::Money.parse('12,34 €')
    assert_equal Mint.money(1500, 'JPY'), Mint::Money.parse('¥1500')
  end

  def test_parse_with_code
    assert_equal Mint.money(1234.56, 'USD'), Mint::Money.parse('USD 1,234.56')
    assert_equal Mint.money(10, 'BRL'), Mint::Money.parse('BRL 10')
  end

  def test_parse_symbol_registered_after_symbol_index_is_cached
    Mint::Money.parse('$1')
    currency = Mint.register_currency!(:PARSE_TEST, subunit: 2, symbol: 'T$', priority: 2000)

    assert_equal currency, Mint::Money.parse('T$1').currency
  end

  def test_parse_us_thousands
    assert_equal Mint.money(1_234_567.89, 'USD'), Mint::Money.parse('$1,234,567.89')
    assert_equal Mint.money(1_234_567.00, 'USD'), Mint::Money.parse('$1,234,567')
    assert_equal Mint.money(1_234_567.11, 'USD'), Mint::Money.parse('$1,234,567.11098')
    assert_equal Mint.money(1_234_567.11, 'USD'), Mint::Money.parse('$1.234.567,11098')
  end

  def test_parse_errors
    assert_raises(ArgumentError) { Mint::Money.parse('') }
    assert_raises(ArgumentError) { Mint::Money.parse('12,344,123.12.123', 'USD') }
    assert_raises(ArgumentError) { Mint::Money.parse(19.99, 'USD') }
    assert_raises(ArgumentError) { Mint::Money.parse('19.99') }
    assert_raises(ArgumentError) { Mint::Money.parse('abc', 'USD') }
    assert_raises(ArgumentError) { Mint::Money.parse('10', 'ZZZ') }
  end
end

# frozen_string_literal: true

using Mint

class MoneyParseTest < Minitest::Test
  def test_parse_with_explicit_currency
    assert_equal Mint.money(19.99, 'USD'), Mint.parse('19.99', 'USD')
    assert_equal Mint.money(1234.56, 'EUR'), Mint.parse('1.234,56', 'EUR')
    assert_equal Mint.money(-1010.5, 'BRL'), Mint.parse('-1.010,50', 'BRL')
    assert_equal Mint.money(-1_123_010.5, 'BRL'), Mint.parse('-1,123,010.50', 'BRL')
  end

  def test_parse_with_explicit_currency_object_or_symbol
    assert_equal Mint.money(19.99, 'USD'), Mint.parse('19.99', 'USD')
    assert_equal Mint.money(19.99, 'USD'), Mint.parse('19.99', Mint.currency('USD'))
  end

  def test_parse_trims_whitespace
    assert_equal Mint.money(19.99, 'USD'), Mint.parse(" \t\n$19.99 \n")
  end

  def test_parse_with_symbol
    assert_equal Mint.money(19.99, 'USD'), Mint.parse('$19.99')
    assert_equal Mint.money(-19.99, 'USD'), Mint.parse('-19.99 $')
    assert_equal Mint.money(12.34, 'EUR'), Mint.parse('12,34 €')
    assert_equal Mint.money(1500, 'JPY'), Mint.parse('¥1500')
    assert_equal Mint.money(2500, 'GBP'), Mint.parse('£2,500.00')
  end

  def test_parse_with_code
    assert_equal Mint.money(1234.56, 'USD'), Mint.parse('USD 1,234.56')
    assert_equal Mint.money(10, 'BRL'), Mint.parse('BRL 10')
    assert_equal Mint.money(1234.56, 'USD'), Mint.parse('1,234.56 USD')
    assert_equal Mint.money(-1.25, 'USD'), Mint.parse('-USD 1.25')
  end

  def test_parse_accounting_negative
    assert_equal Mint.money(-19.99, 'USD'), Mint.parse('($19.99)')
    assert_equal Mint.money(-10.00, 'USD'), Mint.parse('(USD 10.00)')
    assert_equal Mint.money(-12.34, 'EUR'), Mint.parse('(12,34 €)')
    assert_equal Mint.money(-5.00, 'USD'),  Mint.parse('(5.00)', 'USD')
  end

  def test_parse_accounting_negative_with_spaces
    assert_equal Mint.money(-19.99, 'USD'), Mint.parse('( $19.99 )')
    assert_equal Mint.money(-10.00, 'USD'), Mint.parse('( USD 10.00 )')
  end

  def test_parse_accounting_negative_zero
    assert_equal Mint.money(0, 'USD'), Mint.parse('($0.00)')
  end

  def test_parse_symbol_registered_after_symbol_index_is_cached
    Mint.parse('$1')
    currency = Mint.register_currency(code: 'PT_ST', subunit: 2, symbol: 'T$', priority: 2000)

    assert_equal currency, Mint.parse('T$1').currency
    assert_equal currency, Mint.parse('PT_ST 12.23').currency
  end

  def test_parse_us_thousands
    assert_equal Mint.money(1_234_567.89, 'USD'), Mint.parse('$1,234,567.89')
    assert_equal Mint.money(1_234_567.00, 'USD'), Mint.parse('$1,234,567')
    assert_equal Mint.money(1_234_567.11, 'USD'), Mint.parse('$1,234,567.11098')
    assert_equal Mint.money(1_234_567.11, 'USD'), Mint.parse('$1.234.567,11098')
  end

  def test_parse_separator_variants
    assert_equal Mint.money(1.20, 'USD'), Mint.parse('1,2', 'USD')
    assert_equal Mint.money(1.23, 'USD'), Mint.parse('1,23', 'USD')
    assert_equal Mint.money(1234, 'USD'), Mint.parse('1,234', 'USD')
    assert_equal Mint.money(1.23, 'USD'), Mint.parse('1,2345', 'USD')

    assert_equal Mint.money(1234.56, 'USD'), Mint.parse('1,234.56', 'USD')
    assert_equal Mint.money(1234.56, 'USD'), Mint.parse('1.234,56', 'USD')
    assert_equal Mint.money(1_234_567, 'USD'), Mint.parse('1.234.567', 'USD')
  end

  def test_parse_with_code_among_spurious_uppercase_words
    assert_equal Mint.money(10.00, 'USD'), Mint.parse('MAX 10.00 USD')
    assert_equal Mint.money(10.00, 'XXX'), Mint.parse('AVG MIN MAX 10.00 XXX')
    assert_equal Mint.money(10.00, 'EUR'), Mint.parse('10.00 EUR MAX')
  end

  def test_parse_errors
    assert_raises(ArgumentError) { Mint.parse('') }
    assert_raises(ArgumentError) { Mint.parse(" \n\t ") }
    assert_raises(ArgumentError) { Mint.parse('12,344,123.12.123', 'USD') }
    assert_raises(ArgumentError) { Mint.parse(19.99, 'USD') }
    assert_raises(ArgumentError) { Mint.parse('19.99') }
    assert_raises(ArgumentError) { Mint.parse('abc', 'USD') }
    assert_raises(ArgumentError) { Mint.parse('10', 'ZZZ') }
  end
end

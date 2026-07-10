# frozen_string_literal: true

class MoneyParseTest < Minitest::Test
  def test_parse_with_explicit_currency
    assert_equal Money.from(19.99, 'USD'), Mint::Money.parse('19.99', 'USD')
    assert_equal Money.from(1234.56, 'EUR'), Mint::Money.parse('1.234,56', 'EUR')
    assert_equal Money.from(-1010.5, 'BRL'), Mint::Money.parse('-1.010,50', 'BRL')
    assert_equal Money.from(-1_123_010.5, 'BRL'), Mint::Money.parse('-1,123,010.50', 'BRL')
    assert_equal Money.from(19.99, 'BRL'), Mint::Money.parse('19.99 BRL', 'USD')
    assert_equal Money.from(19.99, 'EUR'), Mint::Money.parse('19.99 EUR', 'USD')
  end

  def test_parse_with_explicit_currency_object_or_symbol
    assert_equal Money.from(19.99, 'USD'), Money.parse('19.99', 'USD')
    assert_equal Money.from(19.99, 'USD'), Money.parse('19.99', Money::Currency.for_code('USD'))
  end

  def test_parse_trims_whitespace
    assert_equal Money.from(19.99, 'USD'), Money.parse(" \t\n$19.99 \n")
  end

  def test_parse_with_symbol
    assert_equal Money.from(19.99, 'USD'), Money.parse('$19.99')
    assert_equal Money.from(-19.99, 'USD'), Money.parse('-19.99 $')
    assert_equal Money.from(12.34, 'EUR'), Money.parse('12,34 €')
    assert_equal Money.from(1500, 'JPY'), Money.parse('¥1500')
    assert_equal Money.from(2500, 'GBP'), Money.parse('£2,500.00')
    assert_equal Money.from(2500, 'XAF'), Money.parse('FCFA2,500.00')
  end

  def test_parse_with_code
    assert_equal Money.from(1234.56, 'USD'), Money.parse('USD 1,234.56')
    assert_equal Money.from(10, 'BRL'), Money.parse('BRL 10')
    assert_equal Money.from(1234.56, 'USD'), Money.parse('1,234.56 USD')
    assert_equal Money.from(-1.25, 'USD'), Money.parse('-USD 1.25')
  end

  def test_parse_accounting_negative
    assert_equal Money.from(-19.99, 'USD'), Money.parse('($19.99)')
    assert_equal Money.from(-10.00, 'USD'), Money.parse('(USD 10.00)')
    assert_equal Money.from(-12.34, 'EUR'), Money.parse('(12,34 €)')
    assert_equal Money.from(-5.00, 'USD'),  Money.parse('(5.00)', 'USD')
  end

  def test_parse_accounting_negative_with_spaces
    assert_equal Money.from(-19.99, 'USD'), Money.parse('( $19.99 )')
    assert_equal Money.from(-10.00, 'USD'), Money.parse('( USD 10.00 )')
  end

  def test_parse_accounting_negative_zero
    assert_equal Money.from(0, 'USD'), Money.parse('($0.00)')
  end

  def test_parse_symbol_registered_after_symbol_index_is_cached
    Money.parse('$1')
    currency = Money::Currency.register(code: 'PT_ST', subunit: 2, symbol: 'T$', priority: 2000)

    assert_equal currency, Money.parse('T$1').currency
    assert_equal currency, Money.parse('PT_ST 12.23').currency
  end

  def test_parse_us_thousands
    assert_equal Money.from(1_234_567.89, 'USD'), Money.parse('$1,234,567.89')
    assert_equal Money.from(1_234_567.00, 'USD'), Money.parse('$1,234,567')
    assert_equal Money.from(1_234_567.11, 'USD'), Money.parse('$1,234,567.11098')
    assert_equal Money.from(1_234_567.11, 'USD'), Money.parse('$1.234.567,11098')
  end

  def test_parse_separator_variants
    assert_equal Money.from(1.20, 'USD'), Money.parse('1,2', 'USD')
    assert_equal Money.from(1.23, 'USD'), Money.parse('1,23', 'USD')
    assert_equal Money.from(1234, 'USD'), Money.parse('1,234', 'USD')
    assert_equal Money.from(1.23, 'USD'), Money.parse('1,2345', 'USD')

    assert_equal Money.from(1234.56, 'USD'), Money.parse('1,234.56', 'USD')
    assert_equal Money.from(1234.56, 'USD'), Money.parse('1.234,56', 'USD')
    assert_equal Money.from(1_234_567, 'USD'), Money.parse('1.234.567', 'USD')
  end

  def test_parse_alphabetic_symbols_require_word_boundary
    assert_equal Money.from(10, 'ZAR'), Money.parse('R 10')
    assert_equal Money.from(10, 'BAM'), Money.parse('KM 10')
    assert_equal Money.from(100, 'BRL'), Money.parse('R$100')
    assert_equal Money.from(10, 'MYR'), Money.parse('RM 10')
    assert_equal Money.from(10, 'LSL'), Money.parse('M 10')

    assert_nil Money.parse('CAR 100')
    assert_nil Money.parse('MA3 34.34')
    assert_nil Money.parse('CAR$100')
    assert_nil Money.parse('BOOM 100')
    assert_nil Money.parse('ROCKMUSIC 100')
    assert_nil Money.parse('XYZKM 100')
    assert_nil Money.parse('XYZR 100')
  end

  def test_parse_with_code_among_spurious_uppercase_words
    assert_equal Money.from(10.00, 'USD'), Money.parse('MAX 10.00 USD')
    assert_equal Money.from(10.00, 'XXX'), Money.parse('AVG MIN MAX 10.00 XXX')
    assert_equal Money.from(10.00, 'EUR'), Money.parse('10.00 EUR MAX')
  end

  def test_parse_errors
    assert_raises(ArgumentError) { Mint::Money.parse!('') }
    assert_raises(ArgumentError) { Mint::Money.parse!(" \n\t ") }
    assert_raises(ArgumentError) { Mint::Money.parse!('12,344,123.12.123', 'USD') }
    assert_raises(ArgumentError) { Mint::Money.parse!(19.99, 'USD') }
    assert_raises(ArgumentError) { Money.parse!('19.99') }
    assert_raises(ArgumentError) { Money.parse!('abc', 'USD') }
    assert_raises(ArgumentError) { Money.parse!('10', 'ZZZ') }
    assert_equal Money.from(10.00, 'USD'), Money.parse!('MAX 10.00 USD')
    assert_equal Money.from(10.00, 'XXX'), Money.parse!('AVG MIN MAX 10.00 XXX')
    assert_equal Money.from(10.00, 'EUR'), Money.parse!('10.00 EUR MAX')
  end

  def test_parse_returns_nil_on_failure
    assert_nil Money.parse('')
    assert_nil Money.parse(" \n\t ")
    assert_nil Money.parse('12,344,123.12.123', 'USD')
    assert_nil Money.parse(19.99, 'USD')
    assert_nil Money.parse('19.99')
    assert_nil Money.parse('abc', 'USD')
    assert_nil Money.parse('10', 'ZZZ')
  end

  def test_parse_returns_money_on_success
    assert_equal Money.from(19.99, 'USD'), Money.parse('19.99', 'USD')
  end
end

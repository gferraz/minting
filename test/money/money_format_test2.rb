# frozen_string_literal: true

class MoneyFormatTest2 < Minitest::Test
  F2 = Mint::Money::Formatter2

  unless Money::Currency.for_code('BRL_FUEL')
    FUEL = Money::Currency.register(code: 'BRL_FUEL', subunit: 3, symbol: 'R$')
  end

  def usd_9_99 = Money.from(9.99, 'USD')
  def usd_123_456_789_01 = Money.from(123_456_789.01, 'USD')

  def fmt(money, template = nil, **)
    money.format(template, **, formatter_class: F2)
  end

  def test_numeric_simple_format
    assert_equal '$9.99',    fmt(usd_9_99)
    assert_equal '9',        fmt(usd_9_99, '%<amount>d')
    assert_equal '$9.99',    fmt(usd_9_99, '%<symbol>s%<amount>f')
    assert_equal '$+9.99',   fmt(usd_9_99, '%<symbol>s%<amount>+f')
    assert_equal '-9.99',    fmt(-usd_9_99, '%<amount>f')
  end

  def test_more_numeric_simple_format
    gas = Money.from(3.457, FUEL)

    assert_equal '-9.99',    fmt(-usd_9_99, '%<amount>f')
    assert_equal '9.99',     fmt(usd_9_99, '%<amount>f')
    assert_equal 'R$3.457', gas.to_s
  end

  def test_format_with_disambiguate_symbol
    usd = Money.from(10, 'USD')

    assert_equal '$10.00', fmt(usd)
    assert_equal 'US$10.00', fmt(usd, '%<dsymbol>s%<amount>f')
    assert_equal 'US$ 10.00', fmt(usd, '%<dsymbol>s %<amount>f')
    assert_equal 'C$10.00', fmt(Money.from(10, 'CAD'), '%<dsymbol>s%<amount>f')
    assert_equal 'A$10.00', fmt(Money.from(10, 'AUD'), '%<dsymbol>s%<amount>f')
    assert_equal '€10.00', fmt(Money.from(10, 'EUR'), '%<dsymbol>s%<amount>f')
  end

  def test_thousand_delimiter_format
    money = Money.from(123_456_789.01, 'USD')

    assert_equal '$123,456,789.01', money.to_s
    assert_equal '$-123,456,789.01', (-money).to_s
  end

  def test_decimal_separator_format
    money = Money.from(123_456_789.01, 'USD')

    assert_equal '123-456-789|01', fmt(money, '%<amount>f', thousand: '-', decimal: '|')
    assert_equal '123.456.789|01', fmt(money, '%<amount>f', thousand: '.', decimal: '|')

    assert_equal '-123456789.01', fmt(-money, '%<amount>f', thousand: '')
  end

  def test_numeric_padding_format
    brl = Money.from(12.34, 'BRL')

    assert_equal 'xx      9',
                 fmt(usd_9_99, 'xx%<amount>7d')
    assert_equal '        9.99 USD',
                 fmt(usd_9_99, '%<amount>f %<currency>s', width: 16)
    assert_equal 'R$    +12.34',
                 fmt(brl, '%<symbol>2s%<amount>+10f')
    assert_equal '       -9.99',
                 fmt(-usd_9_99, '%<amount>f', width: 12)
  end

  def test_hash_format
    brl = Money.from(134_120, 'BRL')
    jpy = Money.from(15, 'JPY')
    gas = Money.from(3.457, FUEL)

    assert_equal({ currency: 'BRL', amount: '134120.00' }, brl.to_hash)
    assert_equal({ currency: 'JPY', amount: '15' }, jpy.to_hash)
    assert_equal({ currency: 'BRL_FUEL', amount: '3.457' }, gas.to_hash)
  end

  def test_numeric_html_format
    brl = Money.from(10.05, 'BRL')
    jpy = Money.from(15_000, 'JPY')
    gas = Money.from(3.457, FUEL)

    assert_equal "<data class='money' title='BRL 10.05'>R$10.05</data>", brl.to_html
    assert_equal "<data class='money' title='JPY 15000'>¥15,000</data>", jpy.to_html
    assert_equal "<data class='money' title='BRL_FUEL 3.457'>R$ +3.457</data>", gas.to_html('%<symbol>2s %<amount>+f')
  end

  def test_european_currency_formats
    eur = Money.from(9234.56, 'EUR')
    gbp = Money.from(987.65, 'GBP')
    chf = Money.from(456.78, 'CHF')

    assert_equal '9,234.56 €', fmt(eur, '%<amount>f %<symbol>s', thousand: ',', decimal: '.')
    assert_equal '987.65 £', fmt(gbp, '%<amount>f %<symbol>s')
    assert_equal '456.78 Fr', fmt(chf, '%<amount>f %<symbol>s')

    assert_equal '9.234,56 €', fmt(eur, '%<amount>f %<symbol>s', thousand: '.', decimal: ',')
    assert_equal '987,65 £', fmt(gbp, '%<amount>f %<symbol>s', decimal: ',')
  end

  def test_asian_currency_formats
    jpy = Money.from(123_456, 'JPY')
    krw = Money.from(987_654, 'KRW')
    cny = Money.from(1234.56, 'CNY')
    inr = Money.from(9876.54, 'INR')

    assert_equal '¥123,456', jpy.to_s
    assert_equal '¥123-456', fmt(jpy, thousand: '-')
    assert_equal '₩987,654', krw.to_s
    assert_equal '¥1,234.56', cny.to_s
    assert_equal '₹9,876.54', inr.to_s
  end

  def test_middle_eastern_currency_formats
    sar = Money.from(987.65, 'SAR')
    ils = Money.from(456.78, 'ILS')

    assert_equal 'د.إ1,234.56', Money.from(1234.56, 'AED').to_s
    assert_equal '﷼987.65', sar.to_s
    assert_equal '₪456.78', ils.to_s
  end

  def test_high_precision_currency_formats
    kwd = Money.from(123.456, 'KWD')
    bhd = Money.from(987.654, 'BHD')
    omr = Money.from(456.789, 'OMR')

    assert_equal 'د.ك123.456', kwd.to_s
    assert_equal '.د.ب987.654', bhd.to_s
    assert_equal '﷼456.789', omr.to_s
  end

  def test_accounting_formats
    profit = Money.from(1234.56, 'USD')
    loss = Money.from(-1234.56, 'USD')

    assert_equal '$1,234.56', fmt(profit, { negative: '%<symbol>s(%<amount>f)' })
    assert_equal '$(1,234.56)', fmt(loss, { negative: '%<symbol>s(%<amount>f)' })

    assert_equal '$1,234.56', fmt(profit, { negative: '(%<symbol>s%<amount>f)' })
    assert_equal '($1,234.56)', fmt(loss, { negative: '(%<symbol>s%<amount>f)' })
  end

  def test_invoice_receipt_formats
    total = Money.from(1299.99, 'USD')
    tax = Money.from(104.00, 'USD')

    assert_equal '$   1,299.99', fmt(total, '%<symbol>s%<amount>10.2f')
    assert_equal '$    104.00', fmt(tax, '%<symbol>s%<amount>10.2f')

    assert_equal '   $1,299.99', fmt(total, width: 12)
    assert_equal '     $104.00', fmt(tax, width: 12)
  end

  def test_web_display_formats
    price = Money.from(49.99, 'USD')

    assert_equal '$49.99', price.to_s
    assert_equal '49.99', fmt(price, '%<amount>f')
    assert_equal 'USD 49.99', fmt(price, '%<currency>s %<amount>f')
  end

  def test_mobile_app_formats
    balance = Money.from(12_345.67, 'USD')

    assert_equal '$12,345', fmt(balance, '%<symbol>s%<amount>d')

    balance_in_k = balance / 1000

    assert_equal '12.4K', fmt(balance_in_k, '%<amount>.1fK')
    assert_equal '12K', fmt(balance_in_k, '%<amount>.0fK')
  end

  def test_financial_report_formats
    revenue = Money.from(1_234_567.89, 'USD')

    assert_equal '  $1,234,567.89', fmt(revenue, width: 15)

    millions = revenue / 1_000_000
    thousands = revenue / 1_000

    assert_equal '$1.23M', fmt(millions, '%<symbol>s%<amount>fM')
    assert_equal '$1,234.6K', fmt(thousands, '%<symbol>s%<amount>0.1fK')
    assert_equal '--', fmt(Money.from(0, 'BRL'), { zero: '--' })
  end

  def test_international_space_conventions
    amount = Money.from(1234.56, 'EUR')

    assert_equal '1,234.56 €', fmt(amount, '%<amount>f %<symbol>s')
    assert_equal '1 234,56 €', fmt(amount, '%<amount>f %<symbol>s', thousand: ' ', decimal: ',')
    assert_equal 'EUR 1,234.56', fmt(amount, '%<currency>s %<amount>f')
  end

  def test_zero_and_negative_handling
    zero = Money.from(0, 'USD')
    negative = Money.from(-50.25, 'EUR')

    assert_equal '$0.00', zero.to_s
    assert_equal '$0', fmt(zero, '%<symbol>s%<amount>d')

    assert_equal '€-50.25', negative.to_s
    assert_equal '-50.25', fmt(negative, '%<amount>f')

    assert_equal '(€50.25)', fmt(negative.abs, '(%<symbol>s%<amount>f)')
    assert_equal '(50.25)', fmt(negative.abs, '(%<amount>f)')
  end

  def test_hash_format_with_all_signs
    money = Money.from(1234.56, 'USD')
    loss  = Money.from(-1234.56, 'USD')
    zero  = Money.from(0, 'USD')

    formats = {
      positive: '%<symbol>s%<amount>f',
      negative: '(%<symbol>s%<amount>f)',
      zero: '--'
    }

    assert_equal '$1,234.56', fmt(money, formats)
    assert_equal '($1,234.56)', fmt(loss, formats)
    assert_equal '--', fmt(zero, formats)
  end

  def test_hash_format_missing_positive_falls_back_to_default
    money = Money.from(1234.56, 'USD')

    assert_equal '$1,234.56', fmt(money, { negative: '(%<symbol>s%<amount>f)' })
  end

  def test_hash_format_missing_negative_falls_back_to_positive
    loss = Money.from(-50.25, 'EUR')

    assert_equal '[€-50.25]', fmt(loss, { positive: '[%<symbol>s%<amount>f]' })
  end

  def test_hash_format_zero_without_zero_key_uses_positive
    assert_equal '¤0.0000', fmt(Money.from(0, 'XXX'), { positive: '%<symbol>s%<amount>f' })
  end

  def test_hash_format_with_european_separators
    money = Money.from(1234.56, 'EUR')
    loss  = Money.from(-1234.56, 'EUR')

    formats = {
      positive: '%<amount>f %<symbol>s',
      negative: '(%<amount>f) %<symbol>s'
    }

    assert_equal '1,234.56 €', fmt(money, formats)
    assert_equal '(1,234.56) €', fmt(loss, formats)
    assert_equal '1.234,56 €', fmt(money, formats, thousand: '.', decimal: ',')
  end

  def test_format_rejects_invalid_hash_format
    assert_raises(ArgumentError) { fmt(usd_9_99, 34) }
    assert_raises(ArgumentError) { fmt(usd_9_99, {}) }
    assert_raises(ArgumentError) { fmt(usd_9_99, { foo: 'bar' }) }
    assert_raises(ArgumentError) { fmt(usd_9_99, { positive: '%<amount>f', bananas: '%<amount>d' }) }
    assert_raises(ArgumentError) { fmt(usd_9_99, { 'negative' => 'x' }) }
  end

  def test_format_with_integral_and_fractional_parts
    m = Money.from(1234.56, 'USD')

    assert_equal '1234', fmt(m, '%<integral>d', thousand: '')
    assert_equal '1,234 + 56/100', fmt(m, '%<integral>d + %<fractional>d/100')
    assert_equal ' 1,234_56', fmt(m, '%<integral> d_%<fractional>d')
    assert_equal '-1,234_56', fmt(-m, '%<integral>d_%<fractional>d')
    assert_equal '+1,234_56', fmt(m, '%<integral>+d_%<fractional>d')
    assert_equal '$1,234/56', fmt(m, '%<symbol>s%<integral>d/%<fractional>d')
    assert_equal '1,234', fmt(m, '%<integral>d')
    assert_equal '56 cents', fmt(m, '%<fractional>d cents')

    loss = Money.from(-1234.56, 'USD')

    assert_equal '($1,234/56)', fmt(loss, { negative: '(%<symbol>s%<integral>d/%<fractional>d)' })

    assert_equal '-1,234_56', fmt(loss, '%<integral>d_%<fractional>d')

    jpy = Money.from(1234, 'JPY')

    assert_equal '1,234_0', fmt(jpy, '%<integral>d_%<fractional>d')
  end

  def test_format_with_literal_dot_in_template
    m = Money.from(1234.56, 'USD')

    assert_equal '1,234.5600 1,234.00', fmt(m, '%<amount>0.4f %<integral>d.00')
  end

  def test_format_literal_dot_with_non_dot_decimal
    m = Money.from(1234.56, 'USD')

    assert_equal '1.234,56', fmt(m, '%<amount>f', thousand: '.', decimal: ',')
    assert_equal '1.5x 1.234,56', fmt(m, '1.5x %<amount>f', thousand: '.', decimal: ',')
    assert_equal '3.2% 1.234,56', fmt(m, '3.2%% %<amount>f', thousand: '.', decimal: ',')
  end

  def test_format_multiple_amount_occurrences
    m = Money.from(22_212.45, 'USD')

    assert_equal '$22,212.45 + $22,212.45', fmt(m, '%<symbol>s%<amount>f + %<symbol>s%<amount>f')
    assert_equal '22,212.45 vs 22,212.45', fmt(m, '%<amount>f vs %<amount>f')
    assert_equal '22,212.45 <= 22,212', fmt(m, '%<amount>f <= %<amount>0.f')
  end

  def test_validate_decimal_invalid_type
    assert_raises(ArgumentError) { fmt(usd_9_99, decimal: 123) }
    assert_raises(ArgumentError) { fmt(usd_9_99, decimal: true) }
    assert_raises(ArgumentError) { fmt(usd_9_99, decimal: '') }
  end

  def test_validate_decimal_nil_is_valid
    assert_equal '$9.99', fmt(usd_9_99, decimal: nil)
  end

  def test_validate_thousand_invalid_type
    assert_raises(ArgumentError) { fmt(usd_9_99, thousand: 123) }
    assert_raises(ArgumentError) { fmt(usd_9_99, thousand: true) }
  end

  def test_validate_thousand_nil_and_false_are_valid
    assert_equal '$123,456,789.01', fmt(usd_123_456_789_01, thousand: nil)
    assert_equal '$123456789.01', fmt(usd_123_456_789_01, thousand: false)
  end

  def test_validate_thousand_empty_string_is_valid
    assert_equal '$9.99', fmt(usd_9_99, thousand: '')
  end

  def test_validate_decimal_and_thousand_identical
    assert_raises(ArgumentError) { fmt(usd_9_99, decimal: ',', thousand: ',') }
  end

  def test_validate_decimal_and_thousand_identical_allows_if_one_empty
    assert_equal '9,99', fmt(usd_9_99, '%<amount>f', decimal: ',', thousand: '')
  end

  def test_validate_decimal_and_thousand_different_ok
    assert_equal '$9.99', fmt(usd_9_99, decimal: '.', thousand: ',')
    money = Money.from(1234.56, 'USD')

    assert_equal '1,234.56', fmt(money, '%<amount>f', decimal: '.', thousand: ',')
  end
end

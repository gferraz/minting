# frozen_string_literal: true

class MoneyFormatTest < Minitest::Test
  FUEL = Money::Currency.register(code: 'BRL_FUEL', subunit: 3, symbol: 'R$')

  def usd_9_99 = Money.from(9.99, 'USD')
  def usd_123_456_789_01 = Money.from(123_456_789.01, 'USD')

  def test_numeric_simple_format
    assert_equal '$9.99',    usd_9_99.to_s
    assert_equal '9',        usd_9_99.to_fs('%<amount>d')
    assert_equal '$9.99',    usd_9_99.to_fs('%<symbol>s%<amount>f')
    assert_equal '$+9.99',   usd_9_99.to_fs('%<symbol>s%<amount>+f')
    assert_equal '-9.99',    (-usd_9_99).to_fs('%<amount>f')
  end

  def test_more_numeric_simple_format
    gas = Money.from(3.457, FUEL)

    assert_equal '-9.99',    (-usd_9_99).format('%<amount>f')
    assert_equal '9.99',     usd_9_99.format('%<amount>f')
    assert_equal 'R$3.457', gas.to_s
  end

  def test_format_with_disambiguate_symbol
    usd = Money.from(10, 'USD')

    assert_equal '$10.00', usd.format
    assert_equal 'US$10.00', usd.format('%<dsymbol>s%<amount>f')
    assert_equal 'US$ 10.00', usd.format('%<dsymbol>s %<amount>f')
    assert_equal 'C$10.00', Money.from(10, 'CAD').format('%<dsymbol>s%<amount>f')
    assert_equal 'A$10.00', Money.from(10, 'AUD').format('%<dsymbol>s%<amount>f')
    assert_equal '€10.00', Money.from(10, 'EUR').format('%<dsymbol>s%<amount>f')
  end

  def test_thousand_delimiter_format
    money = Money.from(123_456_789.01, 'USD')

    assert_equal '$123,456,789.01', money.to_s
    assert_equal '$-123,456,789.01', (-money).to_s
  end

  def test_decimal_separator_format
    money = Money.from(123_456_789.01, 'USD')

    assert_equal '123-456-789|01', money.format('%<amount>f', thousand: '-', decimal: '|')
    assert_equal '123.456.789|01', money.format('%<amount>f', thousand: '.', decimal: '|')

    assert_equal '-123456789.01', (-money).format('%<amount>f', thousand: '')
  end

  def test_numeric_padding_format
    brl = Money.from(12.34, 'BRL')

    assert_equal 'xx      9',
                 usd_9_99.format('xx%<amount>7d')
    assert_equal '        9.99 USD',
                 usd_9_99.format('%<amount>f %<currency>s', width: 16)
    assert_equal 'R$    +12.34',
                 brl.format('%<symbol>2s%<amount>+10f')
    assert_equal '       -9.99',
                 (-usd_9_99).format('%<amount>f', width: 12)
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

  # Real-world currency formatting tests
  def test_european_currency_formats
    eur = Money.from(9234.56, 'EUR')
    gbp = Money.from(987.65, 'GBP')
    chf = Money.from(456.78, 'CHF')

    # European style: symbol after amount
    assert_equal '9,234.56 €', eur.format('%<amount>f %<symbol>s', thousand: ',', decimal: '.')
    assert_equal '987.65 £', gbp.format('%<amount>f %<symbol>s')
    assert_equal '456.78 Fr', chf.format('%<amount>f %<symbol>s')

    # European style with comma separator and dot delimiter
    assert_equal '9.234,56 €', eur.format('%<amount>f %<symbol>s', thousand: '.', decimal: ',')
    assert_equal '987,65 £', gbp.format('%<amount>f %<symbol>s', decimal: ',')
  end

  def test_asian_currency_formats
    jpy = Money.from(123_456, 'JPY')
    krw = Money.from(987_654, 'KRW')
    cny = Money.from(1234.56, 'CNY')
    inr = Money.from(9876.54, 'INR')

    # Japanese Yen (no decimals)
    assert_equal '¥123,456', jpy.to_s
    assert_equal '¥123-456', jpy.format(thousand: '-')

    # Korean Won (no decimals)
    assert_equal '₩987,654', krw.to_s

    # Chinese Yuan
    assert_equal '¥1,234.56', cny.to_s

    # Indian Rupee with Indian numbering system style
    assert_equal '₹9,876.54', inr.to_s
  end

  def test_middle_eastern_currency_formats
    sar = Money.from(987.65, 'SAR')
    ils = Money.from(456.78, 'ILS')

    # Middle Eastern currencies - often RTL but displayed LTR in code
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

    # Standard accounting format with parentheses for negative
    assert_equal '$1,234.56', profit.format({ negative: '%<symbol>s(%<amount>f)' })
    assert_equal '$(1,234.56)', loss.format({ negative: '%<symbol>s(%<amount>f)' })

    # Alternative accounting format
    assert_equal '$1,234.56', profit.format({ negative: '(%<symbol>s%<amount>f)' })
    assert_equal '($1,234.56)', loss.format({ negative: '(%<symbol>s%<amount>f)' })
  end

  def test_invoice_receipt_formats
    total = Money.from(1299.99, 'USD')
    tax = Money.from(104.00, 'USD')

    # Receipt/invoice style formatting
    assert_equal '$   1,299.99', total.format('%<symbol>s%<amount>10.2f')
    assert_equal '$    104.00', tax.format('%<symbol>s%<amount>10.2f')

    # Right-aligned amounts
    assert_equal '   $1,299.99', total.format(width: 12)
    assert_equal '     $104.00', tax.format(width: 12)
  end

  def test_web_display_formats
    price = Money.from(49.99, 'USD')

    # E-commerce pricing display
    assert_equal '$49.99', price.to_s

    # Clean web format without symbol
    assert_equal '49.99', price.format('%<amount>f')
    assert_equal 'USD 49.99', price.format('%<currency>s %<amount>f')
  end

  def test_mobile_app_formats
    balance = Money.from(12_345.67, 'USD')

    # Compact mobile display - abbreviated amounts
    assert_equal '$12,345', balance.format('%<symbol>s%<amount>d')

    # Custom abbreviated format
    balance_in_k = balance / 1000

    assert_equal '12.4K', balance_in_k.format('%<amount>.1fK')
    assert_equal '12K', balance_in_k.format('%<amount>.0fK')
  end

  def test_financial_report_formats
    revenue = Money.from(1_234_567.89, 'USD')

    # Financial statement format with padding
    assert_equal '  $1,234,567.89', revenue.format(width: 15)

    # Custom abbreviated formats for reports
    millions = revenue / 1_000_000
    thousands = revenue / 1_000

    assert_equal '$1.23M', millions.format('%<symbol>s%<amount>fM')
    assert_equal '$1,234.6K', thousands.format('%<symbol>s%<amount>0.1fK')
    assert_equal '--', Money.from(0, 'BRL').format({ zero: '--' })
  end

  def test_international_space_conventions
    amount = Money.from(1234.56, 'EUR')

    # French/European convention - space before currency symbol
    assert_equal '1,234.56 €', amount.format('%<amount>f %<symbol>s')
    assert_equal '1 234,56 €', amount.format('%<amount>f %<symbol>s', thousand: ' ', decimal: ',')

    # ISO format
    assert_equal 'EUR 1,234.56', amount.format('%<currency>s %<amount>f')
  end

  def test_zero_and_negative_handling
    zero = Money.from(0, 'USD')
    negative = Money.from(-50.25, 'EUR')

    # Zero formatting
    assert_equal '$0.00', zero.to_s
    assert_equal '$0', zero.format('%<symbol>s%<amount>d')

    # Negative formatting variations
    assert_equal '€-50.25', negative.to_s
    assert_equal '-50.25', negative.format('%<amount>f')

    # Accounting style parentheses for negative
    assert_equal '(€50.25)', negative.abs.format('(%<symbol>s%<amount>f)')
    assert_equal '(50.25)', negative.abs.format('(%<amount>f)')
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

    assert_equal '$1,234.56', money.format(formats)
    assert_equal '($1,234.56)', loss.format(formats)
    assert_equal '--', zero.format(formats)
  end

  def test_hash_format_missing_positive_falls_back_to_default
    # Only :negative is set; positives must still format sensibly via the
    # module default.
    money = Money.from(1234.56, 'USD')

    assert_equal '$1,234.56', money.format({ negative: '(%<symbol>s%<amount>f)' })
  end

  def test_hash_format_missing_negative_falls_back_to_positive
    # No :negative set; negatives use the positive template
    loss = Money.from(-50.25, 'EUR')

    assert_equal '[€-50.25]', loss.format({ positive: '[%<symbol>s%<amount>f]' })
  end

  def test_hash_format_zero_without_zero_key_uses_positive
    assert_equal '¤0.0000', Money.from(0, 'XXX').format({ positive: '%<symbol>s%<amount>f' })
  end

  def test_hash_format_with_european_separators
    money = Money.from(1234.56, 'EUR')
    loss  = Money.from(-1234.56, 'EUR')

    formats = {
      positive: '%<amount>f %<symbol>s',
      negative: '(%<amount>f) %<symbol>s'
    }

    assert_equal '1,234.56 €', money.format(formats)
    assert_equal '(1,234.56) €', loss.format(formats)
    assert_equal '1.234,56 €', money.format(formats, thousand: '.', decimal: ',')
  end

  def test_format_rejects_invalid_hash_format
    assert_raises(ArgumentError) { usd_9_99.format(34) }
    assert_raises(ArgumentError) { usd_9_99.format({}) }
    assert_raises(ArgumentError) { usd_9_99.format({ foo: 'bar' }) }
    assert_raises(ArgumentError) { usd_9_99.format({ positive: '%<amount>f', bananas: '%<amount>d' }) }
    assert_raises(ArgumentError) { usd_9_99.format({ 'negative' => 'x' }) }
  end

  def test_format_with_integral_and_fractional_parts
    m = Money.from(1234.56, 'USD')

    assert_equal '1234', m.format('%<integral>d', thousand: '')
    assert_equal '1,234 + 56/100', m.format('%<integral>d + %<fractional>d/100')
    assert_equal ' 1,234_56', m.format('%<integral> d_%<fractional>d')
    assert_equal '-1,234_56', (-m).format('%<integral>d_%<fractional>d')
    assert_equal '+1,234_56', m.format('%<integral>+d_%<fractional>d')
    assert_equal '$1,234/56', m.format('%<symbol>s%<integral>d/%<fractional>d')
    assert_equal '1,234', m.format('%<integral>d')
    assert_equal '56 cents', m.format('%<fractional>d cents')

    # Composes with hash format too
    loss = Money.from(-1234.56, 'USD')

    assert_equal '($1,234/56)', loss.format({ negative: '(%<symbol>s%<integral>d/%<fractional>d)' })

    # Negative without a custom negative hash template
    assert_equal '-1,234_56', loss.format('%<integral>d_%<fractional>d')

    # Currency with subunit of 0
    jpy = Money.from(1234, 'JPY')

    assert_equal '1,234_0', jpy.format('%<integral>d_%<fractional>d')
  end

  def test_format_with_literal_dot_in_template
    m = Money.from(1234.56, 'USD')

    assert_equal '1,234.5600 1,234.00', m.format('%<amount>0.4f %<integral>d.00')
    # assert_equal 'Discount: 3.2%, Price: 1,234.56', m.format('Discount: 3.2%%, Price: %<amount>f', thousand: ',')
  end

  def test_format_literal_dot_with_non_dot_decimal
    m = Money.from(1234.56, 'USD')

    assert_equal '1.234,56', m.format('%<amount>f', thousand: '.', decimal: ',')
    assert_equal '1.5x 1.234,56', m.format('1.5x %<amount>f', thousand: '.', decimal: ',')
    assert_equal '3.2% 1.234,56', m.format('3.2%% %<amount>f', thousand: '.', decimal: ',')
  end

  def test_format_multiple_amount_occurrences
    m = Money.from(22_212.45, 'USD')

    assert_equal '$22,212.45 + $22,212.45', m.format('%<symbol>s%<amount>f + %<symbol>s%<amount>f')
    assert_equal '22,212.45 vs 22,212.45', m.format('%<amount>f vs %<amount>f')
    assert_equal '22,212.45 <= 22,212', m.format('%<amount>f <= %<amount>0.0f')
  end

  def test_validate_decimal_invalid_type
    assert_raises(ArgumentError) { usd_9_99.format(decimal: 123) }
    assert_raises(ArgumentError) { usd_9_99.format(decimal: true) }
    assert_raises(ArgumentError) { usd_9_99.format(decimal: '') }
  end

  def test_validate_decimal_nil_is_valid
    assert_equal '$9.99', usd_9_99.format(decimal: nil)
  end

  def test_validate_thousand_invalid_type
    assert_raises(ArgumentError) { usd_9_99.format(thousand: 123) }
    assert_raises(ArgumentError) { usd_9_99.format(thousand: true) }
  end

  def test_validate_thousand_nil_and_false_are_valid
    assert_equal '$123,456,789.01', usd_123_456_789_01.format(thousand: nil)
    assert_equal '$123456789.01', usd_123_456_789_01.format(thousand: false)
  end

  def test_validate_thousand_empty_string_is_valid
    assert_equal '$9.99', usd_9_99.format(thousand: '')
  end

  def test_validate_decimal_and_thousand_identical
    assert_raises(ArgumentError) { usd_9_99.format(decimal: ',', thousand: ',') }
  end

  def test_validate_decimal_and_thousand_identical_allows_if_one_empty
    assert_equal '9,99', usd_9_99.format('%<amount>f', decimal: ',', thousand: '')
  end

  def test_validate_decimal_and_thousand_different_ok
    assert_equal '$9.99', usd_9_99.format(decimal: '.', thousand: ',')
    money = Money.from(1234.56, 'USD')

    assert_equal '1,234.56', money.format('%<amount>f', decimal: '.', thousand: ',')
  end
end

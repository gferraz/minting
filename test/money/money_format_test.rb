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

    assert_equal '$123,456,789.01', money.to_s
    assert_equal '$-123,456,789.01', (-money).to_s
  end

  def test_decimal_separator_format
    money = Mint.money(123_456_789.01, 'USD')

    assert_equal '123-456-789|01', money.to_s(format: '%<amount>f', thousand: '-', decimal: '|')
    assert_equal '-123456789.01', (-money).to_s(format: '%<amount>f', thousand: '')
  end

  def test_numeric_padding_format
    usd = Mint.money(9.99, 'USD')
    brl = Mint.money(12.34, 'BRL')

    assert_equal 'xx      9',
                 usd.to_s(format: 'xx%<amount>7d')
    assert_equal '        9.99 USD',
                 usd.to_s(format: '%<amount>f %<currency>s', width: 16)
    assert_equal 'R$    +12.34',
                 brl.to_s(format: '%<symbol>2s%<amount>+10f')
    assert_equal '       -9.99',
                 (-usd).to_s(format: '%<amount>f', width: 12)
  end

  def test_numeric_json_format
    brl = Mint.money(134_120, 'BRL')
    jpy = Mint.money(15, 'JPY')
    gas = Mint.money(3.457, FUEL)

    assert_equal '{"currency": "BRL", "amount": "134120.00"}', brl.to_json
    assert_equal '{"currency": "JPY", "amount": "15"}', jpy.to_json
    assert_equal '{"currency": "BRL_FUEL", "amount": "3.457"}', gas.to_json
  end

  def test_numeric_html_format
    brl = Mint.money(10.05, 'BRL')
    jpy = Mint.money(15_000, 'JPY')
    gas = Mint.money(3.457, FUEL)

    assert_equal "<data class='money' title='BRL 10.05'>R$10.05</data>",
                 brl.to_html
    assert_equal "<data class='money' title='JPY 15000'>¥15,000</data>",
                 jpy.to_html
    assert_equal "<data class='money' title='BRL_FUEL 3.457'>R$ +3.457</data>",
                 gas.to_html('%<symbol>2s %<amount>+f')
  end

  # Real-world currency formatting tests
  def test_european_currency_formats
    eur = Mint.money(1234.56, 'EUR')
    gbp = Mint.money(987.65, 'GBP')
    chf = Mint.money(456.78, 'CHF')

    # European style: symbol after amount
    assert_equal '1,234.56 €', eur.to_s(format: '%<amount>f %<symbol>s')
    assert_equal '987.65 £', gbp.to_s(format: '%<amount>f %<symbol>s')
    assert_equal '456.78 Fr', chf.to_s(format: '%<amount>f %<symbol>s')

    # European style with comma separator and dot delimiter
    assert_equal '1.234,56 €', eur.to_s(format: '%<amount>f %<symbol>s',
                                        thousand: '.', decimal: ',')
    assert_equal '987,65 £', gbp.to_s(format: '%<amount>f %<symbol>s', decimal: ',')
  end

  def test_asian_currency_formats
    jpy = Mint.money(123_456, 'JPY')
    krw = Mint.money(987_654, 'KRW')
    cny = Mint.money(1234.56, 'CNY')
    inr = Mint.money(9876.54, 'INR')

    # Japanese Yen (no decimals)
    assert_equal '¥123,456', jpy.to_s
    assert_equal '¥123-456', jpy.to_s(thousand: '-')

    # Korean Won (no decimals)
    assert_equal '₩987,654', krw.to_s

    # Chinese Yuan
    assert_equal '¥1,234.56', cny.to_s

    # Indian Rupee with Indian numbering system style
    assert_equal '₹9,876.54', inr.to_s
  end

  def test_middle_eastern_currency_formats
    aed = Mint.money(1234.56, 'AED')
    sar = Mint.money(987.65, 'SAR')
    ils = Mint.money(456.78, 'ILS')

    # Middle Eastern currencies - often RTL but displayed LTR in code
    assert_equal 'د.إ1,234.56', aed.to_s
    assert_equal '﷼987.65', sar.to_s
    assert_equal '₪456.78', ils.to_s
  end

  def test_african_currency_formats
    zar = Mint.money(1234.56, 'ZAR')
    egp = Mint.money(987.65, 'EGP')
    ngn = Mint.money(12_345.67, 'NGN')

    # South African Rand
    assert_equal 'R1,234.56', zar.to_s

    # Egyptian Pound
    assert_equal '£987.65', egp.to_s

    # Nigerian Naira
    assert_equal '₦12,345.67', ngn.to_s
  end

  def test_americas_currency_formats
    usd = Mint.money(1234.56, 'USD')
    brl = Mint.money(9876.54, 'BRL')
    mxn = Mint.money(2345.67, 'MXN')
    cad = Mint.money(3456.78, 'CAD')

    assert_equal '$1,234.56', usd.to_s
    assert_equal 'R$9,876.54', brl.to_s
    assert_equal '$2,345.67', mxn.to_s

    # Canadian Dollar - sometimes shown as CAD prefix
    assert_equal '$3,456.78', cad.to_s
    assert_equal 'CAD 3,456.78', cad.to_s(format: '%<currency>s %<amount>f')
  end

  def test_high_precision_currency_formats
    kwd = Mint.money(123.456, 'KWD')
    bhd = Mint.money(987.654, 'BHD')
    omr = Mint.money(456.789, 'OMR')

    # Kuwaiti Dinar (3 decimal places)
    assert_equal 'د.ك123.456', kwd.to_s

    # Bahraini Dinar (3 decimal places)
    assert_equal '.د.ب987.654', bhd.to_s

    # Omani Rial (3 decimal places)
    assert_equal '﷼456.789', omr.to_s
  end

  def test_accounting_formats
    profit = Mint.money(1234.56, 'USD')
    loss = Mint.money(-1234.56, 'USD')

    # Standard accounting format with parentheses for negative
    assert_equal '$1,234.56', profit.to_s(format: { negative: '%<symbol>s(%<amount>f)' })
    assert_equal '$(1,234.56)', loss.to_s(format: { negative: '%<symbol>s(%<amount>f)' })

    # Alternative accounting format
    assert_equal '$1,234.56', profit.to_s(format: { negative: '(%<symbol>s%<amount>f)' })
    assert_equal '($1,234.56)', loss.to_s(format: { negative: '(%<symbol>s%<amount>f)' })
  end

  def test_invoice_receipt_formats
    total = Mint.money(1299.99, 'USD')
    tax = Mint.money(104.00, 'USD')

    # Receipt/invoice style formatting
    assert_equal '$   1,299.99', total.to_s(format: '%<symbol>s%<amount>10.2f')
    assert_equal '$    104.00', tax.to_s(format: '%<symbol>s%<amount>10.2f')

    # Right-aligned amounts
    assert_equal '   $1,299.99', total.to_s(width: 12)
    assert_equal '     $104.00', tax.to_s(width: 12)
  end

  def test_web_display_formats
    price = Mint.money(49.99, 'USD')

    # E-commerce pricing display
    assert_equal '$49.99', price.to_s

    # Clean web format without symbol
    assert_equal '49.99', price.to_s(format: '%<amount>f')
    assert_equal 'USD 49.99', price.to_s(format: '%<currency>s %<amount>f')
  end

  def test_mobile_app_formats
    balance = Mint.money(12_345.67, 'USD')

    # Compact mobile display - abbreviated amounts
    assert_equal '$12,345', balance.to_s(format: '%<symbol>s%<amount>d')

    # Custom abbreviated format
    balance_in_k = balance / 1000

    assert_equal '12.4K', balance_in_k.to_s(format: '%<amount>.1fK')
    assert_equal '12K', balance_in_k.to_s(format: '%<amount>.0fK')
  end

  def test_financial_report_formats
    revenue = Mint.money(1_234_567.89, 'USD')

    # Financial statement format with padding
    assert_equal '  $1,234,567.89', revenue.to_s(width: 15)

    # Custom abbreviated formats for reports
    millions = revenue / 1_000_000
    thousands = revenue / 1_000

    assert_equal '$1.23M', millions.to_s(format: '%<symbol>s%<amount>fM')
    assert_equal '$1,234.6K', thousands.to_s(format: '%<symbol>s%<amount>0.1fK')
    assert_equal '--', Mint.money(0, 'BRL').to_s(format: { zero: '--' })
  end

  def test_international_space_conventions
    amount = Mint.money(1234.56, 'EUR')

    # French/European convention - space before currency symbol
    assert_equal '1,234.56 €', amount.to_s(format: '%<amount>f %<symbol>s')
    assert_equal '1 234,56 €', amount.to_s(format: '%<amount>f %<symbol>s',
                                           thousand: ' ', decimal: ',')

    # ISO format
    assert_equal 'EUR 1,234.56', amount.to_s(format: '%<currency>s %<amount>f')
  end

  def test_zero_and_negative_handling
    zero = Mint.money(0, 'USD')
    negative = Mint.money(-50.25, 'EUR')

    # Zero formatting
    assert_equal '$0.00', zero.to_s
    assert_equal '$0', zero.to_s(format: '%<symbol>s%<amount>d')

    # Negative formatting variations
    assert_equal '€-50.25', negative.to_s
    assert_equal '-50.25', negative.to_s(format: '%<amount>f')

    # Accounting style parentheses for negative
    assert_equal '(€50.25)', negative.abs.to_s(format: '(%<symbol>s%<amount>f)')
    assert_equal '(50.25)', negative.abs.to_s(format: '(%<amount>f)')
  end
end

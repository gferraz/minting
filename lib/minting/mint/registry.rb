# :nodoc
module Mint
  def self.money(amount, currency_code)
    currency = currency(currency_code)
    return Money.new(amount, currency).freeze if currency

    available = currencies.keys.join(', ')
    raise ArgumentError, "Currency [#{currency_code}] not registered. Available: #{available}"
  end

  def self.currency(currency)
    case currency
    when Currency
      currency
    when Symbol
      currencies[currency.to_s]
    else
      currencies[currency]
    end
  end

  def self.register_currency(code, subunit: 2, symbol: '$')
    code = code.to_s
    currencies[code] || register_currency!(code, subunit: subunit, symbol: symbol)
  end

  def self.register_currency!(code, subunit:, symbol: '')
    code = code.to_s
    unless code.match?(/^[A-Z_]+$/)
      raise ArgumentError,
            "Currency code must be String or Symbol ('USD', :EUR, 'FUEL', 'MY_COIN')"
    end
    if currencies[code]
      raise KeyError,
            "Currency: #{code} already registered"
    end

    currencies[code] =
      Currency.new(code, subunit: subunit.to_i, symbol: symbol.to_s).freeze
  end

  def self.currencies
    @currencies ||= {
      # Major Global Currencies
      'USD' => Currency.new('USD', subunit: 2, symbol: '$'),
      'EUR' => Currency.new('EUR', subunit: 2, symbol: '€'),
      'GBP' => Currency.new('GBP', subunit: 2, symbol: '£'),
      'JPY' => Currency.new('JPY', subunit: 0, symbol: '¥'),
      'CHF' => Currency.new('CHF', subunit: 2, symbol: 'Fr'),
      'CAD' => Currency.new('CAD', subunit: 2, symbol: '$'),
      'AUD' => Currency.new('AUD', subunit: 2, symbol: '$'),
      'CNY' => Currency.new('CNY', subunit: 2, symbol: '¥'),
      'SEK' => Currency.new('SEK', subunit: 2, symbol: 'kr'),
      'NZD' => Currency.new('NZD', subunit: 2, symbol: '$'),

      # Asia-Pacific
      'HKD' => Currency.new('HKD', subunit: 2, symbol: 'HK$'),
      'SGD' => Currency.new('SGD', subunit: 2, symbol: 'S$'),
      'KRW' => Currency.new('KRW', subunit: 0, symbol: '₩'),
      'INR' => Currency.new('INR', subunit: 2, symbol: '₹'),
      'THB' => Currency.new('THB', subunit: 2, symbol: '฿'),
      'MYR' => Currency.new('MYR', subunit: 2, symbol: 'RM'),
      'IDR' => Currency.new('IDR', subunit: 2, symbol: 'Rp'),
      'PHP' => Currency.new('PHP', subunit: 2, symbol: '₱'),
      'VND' => Currency.new('VND', subunit: 0, symbol: '₫'),
      'TWD' => Currency.new('TWD', subunit: 2, symbol: 'NT$'),
      'PKR' => Currency.new('PKR', subunit: 2, symbol: '₨'),
      'BDT' => Currency.new('BDT', subunit: 2, symbol: '৳'),
      'LKR' => Currency.new('LKR', subunit: 2, symbol: '₨'),
      'NPR' => Currency.new('NPR', subunit: 2, symbol: '₨'),
      'MMK' => Currency.new('MMK', subunit: 2, symbol: 'K'),
      'KHR' => Currency.new('KHR', subunit: 2, symbol: '៛'),
      'LAK' => Currency.new('LAK', subunit: 2, symbol: '₭'),
      'BND' => Currency.new('BND', subunit: 2, symbol: 'B$'),

      # Middle East & Central Asia
      'AED' => Currency.new('AED', subunit: 2, symbol: 'د.إ'),
      'SAR' => Currency.new('SAR', subunit: 2, symbol: '﷼'),
      'QAR' => Currency.new('QAR', subunit: 2, symbol: '﷼'),
      'KWD' => Currency.new('KWD', subunit: 3, symbol: 'د.ك'),
      'BHD' => Currency.new('BHD', subunit: 3, symbol: '.د.ب'),
      'OMR' => Currency.new('OMR', subunit: 3, symbol: '﷼'),
      'JOD' => Currency.new('JOD', subunit: 3, symbol: 'د.ا'),
      'ILS' => Currency.new('ILS', subunit: 2, symbol: '₪'),
      'TRY' => Currency.new('TRY', subunit: 2, symbol: '₺'),
      'IRR' => Currency.new('IRR', subunit: 2, symbol: '﷼'),
      'IQD' => Currency.new('IQD', subunit: 3, symbol: 'د.ع'),
      'AFN' => Currency.new('AFN', subunit: 2, symbol: '؋'),
      'KZT' => Currency.new('KZT', subunit: 2, symbol: '₸'),
      'UZS' => Currency.new('UZS', subunit: 2, symbol: 'лв'),
      'KGS' => Currency.new('KGS', subunit: 2, symbol: 'лв'),
      'TJS' => Currency.new('TJS', subunit: 2, symbol: 'SM'),

      # Europe
      'NOK' => Currency.new('NOK', subunit: 2, symbol: 'kr'),
      'DKK' => Currency.new('DKK', subunit: 2, symbol: 'kr'),
      'ISK' => Currency.new('ISK', subunit: 0, symbol: 'kr'),
      'PLN' => Currency.new('PLN', subunit: 2, symbol: 'zł'),
      'CZK' => Currency.new('CZK', subunit: 2, symbol: 'Kč'),
      'HUF' => Currency.new('HUF', subunit: 2, symbol: 'Ft'),
      'RON' => Currency.new('RON', subunit: 2, symbol: 'lei'),
      'BGN' => Currency.new('BGN', subunit: 2, symbol: 'лв'),
      'HRK' => Currency.new('HRK', subunit: 2, symbol: 'kn'),
      'RSD' => Currency.new('RSD', subunit: 2, symbol: 'Дин.'),
      'RUB' => Currency.new('RUB', subunit: 2, symbol: '₽'),
      'UAH' => Currency.new('UAH', subunit: 2, symbol: '₴'),
      'BYN' => Currency.new('BYN', subunit: 2, symbol: 'Br'),
      'MDL' => Currency.new('MDL', subunit: 2, symbol: 'L'),
      'GEL' => Currency.new('GEL', subunit: 2, symbol: '₾'),
      'AMD' => Currency.new('AMD', subunit: 2, symbol: '֏'),
      'AZN' => Currency.new('AZN', subunit: 2, symbol: '₼'),

      # Africa
      'ZAR' => Currency.new('ZAR', subunit: 2, symbol: 'R'),
      'EGP' => Currency.new('EGP', subunit: 2, symbol: '£'),
      'NGN' => Currency.new('NGN', subunit: 2, symbol: '₦'),
      'KES' => Currency.new('KES', subunit: 2, symbol: 'KSh'),
      'GHS' => Currency.new('GHS', subunit: 2, symbol: '¢'),
      'UGX' => Currency.new('UGX', subunit: 0, symbol: 'USh'),
      'TZS' => Currency.new('TZS', subunit: 2, symbol: 'TSh'),
      'ETB' => Currency.new('ETB', subunit: 2, symbol: 'Br'),
      'MAD' => Currency.new('MAD', subunit: 2, symbol: 'د.م.'),
      'TND' => Currency.new('TND', subunit: 3, symbol: 'د.ت'),
      'DZD' => Currency.new('DZD', subunit: 2, symbol: 'د.ج'),
      'LYD' => Currency.new('LYD', subunit: 3, symbol: 'ل.د'),
      'AOA' => Currency.new('AOA', subunit: 2, symbol: 'Kz'),
      'BWP' => Currency.new('BWP', subunit: 2, symbol: 'P'),
      'NAD' => Currency.new('NAD', subunit: 2, symbol: 'N$'),
      'SZL' => Currency.new('SZL', subunit: 2, symbol: 'L'),
      'LSL' => Currency.new('LSL', subunit: 2, symbol: 'L'),
      'MZN' => Currency.new('MZN', subunit: 2, symbol: 'MT'),
      'ZMW' => Currency.new('ZMW', subunit: 2, symbol: 'ZK'),
      'MWK' => Currency.new('MWK', subunit: 2, symbol: 'MK'),
      'RWF' => Currency.new('RWF', subunit: 0, symbol: 'R₣'),
      'BIF' => Currency.new('BIF', subunit: 0, symbol: 'FBu'),

      # Americas
      'MXN' => Currency.new('MXN', subunit: 2, symbol: '$'),
      'BRL' => Currency.new('BRL', subunit: 2, symbol: 'R$'),
      'ARS' => Currency.new('ARS', subunit: 2, symbol: '$'),
      'CLP' => Currency.new('CLP', subunit: 0, symbol: '$'),
      'PEN' => Currency.new('PEN', subunit: 2, symbol: 'S/.'),
      'COP' => Currency.new('COP', subunit: 2, symbol: '$'),
      'VES' => Currency.new('VES', subunit: 2, symbol: 'Bs.'),
      'UYU' => Currency.new('UYU', subunit: 2, symbol: '$U'),
      'PYG' => Currency.new('PYG', subunit: 0, symbol: 'Gs'),
      'BOB' => Currency.new('BOB', subunit: 2, symbol: '$b'),
      'CRC' => Currency.new('CRC', subunit: 2, symbol: '₡'),
      'GTQ' => Currency.new('GTQ', subunit: 2, symbol: 'Q'),
      'HNL' => Currency.new('HNL', subunit: 2, symbol: 'L'),
      'NIO' => Currency.new('NIO', subunit: 2, symbol: 'C$'),
      'PAB' => Currency.new('PAB', subunit: 2, symbol: 'B/.'),
      'DOP' => Currency.new('DOP', subunit: 2, symbol: 'RD$'),
      'HTG' => Currency.new('HTG', subunit: 2, symbol: 'G'),
      'JMD' => Currency.new('JMD', subunit: 2, symbol: 'J$'),
      'TTD' => Currency.new('TTD', subunit: 2, symbol: 'TT$'),
      'BBD' => Currency.new('BBD', subunit: 2, symbol: 'Bds$'),
      'BSD' => Currency.new('BSD', subunit: 2, symbol: 'B$'),
      'BZD' => Currency.new('BZD', subunit: 2, symbol: 'BZ$'),
      'GYD' => Currency.new('GYD', subunit: 2, symbol: 'G$'),
      'SRD' => Currency.new('SRD', subunit: 2, symbol: 'Sr$'),

      # Pacific & Others
      'FJD' => Currency.new('FJD', subunit: 2, symbol: 'FJ$'),
      'PGK' => Currency.new('PGK', subunit: 2, symbol: 'K'),
      'SBD' => Currency.new('SBD', subunit: 2, symbol: 'SI$'),
      'VUV' => Currency.new('VUV', subunit: 0, symbol: 'VT'),
      'TOP' => Currency.new('TOP', subunit: 2, symbol: 'T$'),
      'WST' => Currency.new('WST', subunit: 2, symbol: 'WS$'),
      'XCD' => Currency.new('XCD', subunit: 2, symbol: 'EC$'),
      'XOF' => Currency.new('XOF', subunit: 0, symbol: 'CFA'),
      'XAF' => Currency.new('XAF', subunit: 0, symbol: 'FCFA'),
      'XPF' => Currency.new('XPF', subunit: 0, symbol: '₣')
    }
  end
end

# :nodoc
module Mint
  def self.money(amount, currency_code)
    currency = currency(currency_code)
    return Money.new(amount, currency) if currency

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
      'AUD' => Currency.new('AUD', subunit: 2, symbol: '$'),
      'BRL' => Currency.new('BRL', subunit: 2, symbol: 'R$'),
      'CAD' => Currency.new('CAD', subunit: 2, symbol: '$'),
      'CHF' => Currency.new('CHF', subunit: 2, symbol: 'Fr'),
      'CNY' => Currency.new('CNY', subunit: 2, symbol: '¥'),
      'EUR' => Currency.new('EUR', subunit: 2, symbol: '€'),
      'GBP' => Currency.new('GBP', subunit: 2, symbol: '£'),
      'JPY' => Currency.new('JPY', subunit: 0, symbol: '¥'),
      'MXN' => Currency.new('MXN', subunit: 2, symbol: '$'),
      'NZD' => Currency.new('NZD', subunit: 2, symbol: '$'),
      'PEN' => Currency.new('PEN', subunit: 2, symbol: 'S/.'),
      'SEK' => Currency.new('SEK', subunit: 2, symbol: 'kr'),
      'USD' => Currency.new('USD', subunit: 2, symbol: '$')
    }
  end
end

class Mint
  # :nodoc
  class Currency
    def self.[](currency)
      return currency if currency.is_a? Currency

      currencies[currency.to_s] || currencies[nil]
    end

    def self.register(code, subunit:, symbol: '')
      code = code.to_s
      currencies[code] || register!(code, subunit: subunit, symbol: symbol)
    end

    def self.register!(code, subunit:, symbol: '')
      code = code.to_s
      raise ArgumentError, "Currency code must be String or Symbol ('USD', :EUR)" unless code.match?(/^[A-Z_]+$/)
      raise KeyError,      "Currency: #{code} already registered" if currencies[code]

      currencies[code] = Currency.new(code, subunit: subunit.to_i, symbol: symbol.to_s).freeze
    end

    def self.currencies
      @currencies ||= {
        'AUD' => Currency.new('AUD', subunit: 2, symbol: '$'),
        'BRL' => Currency.new('BRL', subunit: 2, symbol: 'R$'),
        'CAD' => Currency.new('CAD', subunit: 2, symbol: 'R$'),
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
end

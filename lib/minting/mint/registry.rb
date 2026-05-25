require 'yaml'

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
    @currencies ||= load_currencies
  end

  def self.load_currencies
    path = File.expand_path('../data/currencies.yaml', __dir__)
    YAML.load_file(path).each_with_object({}) do |(code, attrs), registry|
      registry[code] = Currency.new(
        code,
        subunit: attrs['subunit'],
        symbol: attrs['symbol']
      ).freeze
    end
  end
  private_class_method :load_currencies
end

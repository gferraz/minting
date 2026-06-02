require 'yaml'

module Mint
  # Creates a new {Money} instance with the given amount and currency code.
  #
  # @param amount [Numeric] the financial value
  # @param currency_code [String, Symbol] the ISO currency code or symbol
  # @return [Money] the instantiated Money object
  # @raise [ArgumentError] if the currency code is not registered
  def self.money(amount, currency_code)
    currency = currency(currency_code)
    return Money.create(amount, currency) if currency

    raise ArgumentError, "[#{currency.inspect}] is not a registered currency. Check Mint.currencies"
  end

  # Returns default zero, no currency money
  def self.zero = @zero ||= Money.new(0, Mint.currency('XXX'))

  # Finds a registered currency by its code, symbol,
  # or retrieves it directly if already a Currency object.
  #
  # @param currency [String, Symbol, Currency] the currency identifier or object
  # @return [Currency, nil] the registered Currency instance or nil if not found
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

  # Registers a new currency if not already registered.
  #
  # @param code [String, Symbol] the unique currency code (e.g. 'USD', :EUR)
  # @param subunit [Integer] the decimal subunit precision (defaults to 2)
  # @param symbol [String] the display symbol (defaults to '')
  # @param priority [Integer] parser precedence priority (defaults to 0)
  # @return [Currency] the registered or existing Currency instance
  # @raise [ArgumentError] if the code layout is invalid or register throws an error
  def self.register_currency(code:, subunit: 2, symbol: '', priority: 0)
    code = code.to_s
    currencies[code] || register_currency!(code:, subunit:, symbol:, priority:)
  end

  # Strictly registers a new currency, raising a KeyError if already registered.
  #
  # @param code [String, Symbol] the unique currency code
  # @param subunit [Integer] the decimal subunit precision
  # @param symbol [String] the display symbol
  # @param priority [Integer] parser precedence priority
  # @return [Currency] the newly registered Currency instance
  # @raise [ArgumentError] if the code contains invalid characters
  # @raise [KeyError] if the currency code is already registered
  def self.register_currency!(code:, subunit:, symbol: '', priority: 0)
    code = code.to_s
    unless code.match?(/^[A-Z_]+$/)
      raise ArgumentError,
            "Currency code must be String or Symbol ('USD', :EUR, 'FUEL', 'MY_COIN')"
    end
    if currencies[code]
      raise KeyError,
            "Currency: #{code} already registered"
    end

    currency = currencies[code] = Currency.new(code:, subunit:, symbol:, priority:)
    @currency_symbols = nil
    currency
  end

  # Returns the hash of all registered currencies.
  #
  # @return [Hash{String => Currency}] registered currencies mapped by code
  def self.currencies
    @currencies ||= begin
      registry = { 'XXX' => Currency.new(code: 'XXX', name: 'No currency', symbol: '¤') }
      load_currencies(registry)
    end
  end

  # Registered symbols sorted for detection: longest match wins, then parser priority.
  def self.currency_symbols
    @currency_symbols ||= begin
      currencies.values
                .map { |currency| [currency.symbol, currency] }
                .reject { |symbol, _| symbol.empty? }
                .sort_by { |symbol, currency| [-symbol.length, -currency.priority] }
    end.freeze
  end

  def self.load_currencies(registry)
    base = File.expand_path('../data', __dir__)
    path = File.join(base, 'currencies.yaml')

    data = YAML.load_file(path)
    data.each do |entry|
      code = entry['code']
      registry[code] = Currency.new(
        code: code,
        subunit: entry['subunit'],
        symbol: entry['symbol'],
        priority: entry['priority'],
        country: entry['country'],
        name: entry['name']
      )
    end
    registry
  end

  private_class_method :load_currencies
end

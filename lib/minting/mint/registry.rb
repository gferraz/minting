# frozen_string_literal: true

# Mint currency registration and factory (public API)
module Mint
  # Registers a new currency if not already registered.
  #
  # @param code [String] the unique currency code (e.g. 'USD', 'EUR')
  # @param subunit [Integer] the decimal subunit precision (defaults to 2)
  # @param symbol [String] the display symbol (defaults to '')
  # @param priority [Integer] parser precedence priority (defaults to 0)
  # @return [Currency] the registered or existing Currency instance
  # @raise [ArgumentError] if the code layout is invalid or register throws an error
  def self.register_currency(code:, subunit: 0, symbol: '', priority: 0)
    Registry.currencies[code] || register_currency!(code:, subunit:, symbol:, priority:)
  end

  # Strictly registers a new currency, raising a KeyError if already registered.
  #
  # @param code [String] the unique currency code
  # @param subunit [Integer] the decimal subunit precision
  # @param symbol [String] the display symbol
  # @param priority [Integer] parser precedence priority
  # @return [Currency] the newly registered Currency instance
  # @raise [ArgumentError] if the code contains invalid characters
  # @raise [KeyError] if the currency code is already registered
  def self.register_currency!(code:, subunit:, symbol: '', priority: 0)
    raise ArgumentError, 'Currency code must be String' unless code.is_a? String
    unless code.match?(/^[A-Z_]+$/)
      raise ArgumentError,
            "Currency code must only letters or '_' ('USD',, 'MY_COIN')"
    end

    currencies = Registry.currencies
    raise KeyError, "Currency: #{code} already registered" if currencies[code]

    currency = currencies[code] = Currency.new(code:, subunit:, symbol:, priority:)
    Registry.invalidate_symbols_cache
    currency
  end

  # Registered symbols sorted for detection: longest match wins, then parser priority.
  # Internal API - used by Money parser.
  #
  # @return [Array<Array<String, Currency>>] sorted symbol-to-currency mappings
  # @api private
  def self.currency_symbols
    Registry.currency_symbols
  end
end

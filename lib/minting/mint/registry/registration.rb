# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    # Registers a new currency, raising a KeyError if already registered.
    #
    # @param code [String] the unique currency code
    # @param subunit [Integer] the decimal subunit precision, defaults to 0
    # @param symbol [String] the display symbol
    # @param priority [Integer] parser precedence priority
    # @return [Currency] the newly registered Currency instance
    # @raise [ArgumentError] if the code contains invalid characters
    # @raise [KeyError] if the currency code is already registered
    def self.register(code:, subunit: 0, symbol: '', priority: 0)
      raise ArgumentError, 'Currency code must be String' unless code.is_a? String
      unless code.match?(/^[A-Z_]+$/)
        raise ArgumentError,
              "Currency code must have only letters or '_' ('USD',, 'MY_COIN')"
      end

      MUTEX.synchronize do
        raise KeyError, "Currency: #{code} already registered" if currencies[code]

        currency = Currency.new(code:, subunit:, symbol:, priority:)
        @currencies = @currencies.merge(code => currency).freeze
        @currency_symbols = nil
        @currency_symbol_map = nil
        currency
      end
    end
  end
end

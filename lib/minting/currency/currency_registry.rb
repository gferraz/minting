# frozen_string_literal: true

require 'yaml'

# Mint currency store (internal)
module Mint
  # Internal currency registry
  # Manages the registry cache and currency symbol lookups.
  module CurrencyRegistry
    extend self

    MUTEX = Monitor.new

    private_constant :MUTEX

    # Returns the frozen hash of all registered currencies.
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def currencies
      @currencies || MUTEX.synchronize { @currencies = Mint.world_currencies.dup.freeze }
    end

    # Registered symbols sorted for detection: longest match wins, then parser priority.
    #
    # @return [Array<Array<String, Currency>>] sorted symbol-to-currency mappings
    # @api private
    def currency_symbols
      @currency_symbols || MUTEX.synchronize do
        @currency_symbols =
          currencies.values
                    .reject { |currency| currency.symbol.empty? }
                    .map { |currency| [currency.symbol, currency] }
                    .sort_by { |symbol, currency| [-symbol.length, -currency.priority] }
                    .freeze
      end
    end

    # Registers a new currency, raising a KeyError if already registered.
    #
    # @param code [String] the unique currency code
    # @param subunit [Integer] the decimal subunit precision, defaults to 0
    # @param symbol [String] the display symbol
    # @param priority [Integer] parser precedence priority
    # @return [Currency] the newly registered Currency instance
    # @raise [ArgumentError] if the code contains invalid characters
    # @raise [KeyError] if the currency code is already registered
    def register(code:, subunit: 0, symbol: '', priority: 0)
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
        currency
      end
    end
  end
end

# frozen_string_literal: true

require 'yaml'

# Mint currency store (internal)
module Mint
  # Internal currency registry
  # Manages the registry cache and currency symbol lookups.
  module CurrencyRegistry
    extend self

    # Returns the hash of all registered currencies.
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def currencies
      @currencies ||= Mint.world_currencies.dup
    end

    # Registered symbols sorted for detection: longest match wins, then parser priority.
    #
    # @return [Array<Array<String, Currency>>] sorted symbol-to-currency mappings
    # @api private
    def currency_symbols
      @currency_symbols ||= begin
        currencies.values
                  .reject { it.symbol.empty? }
                  .map { |currency| [currency.symbol, currency] }
                  .sort_by { |symbol, currency| [-symbol.length, -currency.priority] }
      end.freeze
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

      currencies = CurrencyRegistry.currencies
      raise KeyError, "Currency: #{code} already registered" if currencies[code]

      currency = currencies[code] = Currency.new(code:, subunit:, symbol:, priority:)
      invalidate_symbols_cache
      currency
    end

    private

    # Clears and refreshes the currency symbol cache.
    # Called when currencies are registered.
    #
    # @api private
    def invalidate_symbols_cache
      @currency_symbols = nil
    end
  end
end

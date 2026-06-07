# frozen_string_literal: true

require 'yaml'

# Mint currency store (internal)
module Mint
  # Internal currency storage and loading.
  # Manages the registry cache and currency symbol lookups.
  module CurrencyStore
    # Returns the hash of all registered currencies.
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def self.currencies
      @currencies ||= Mint.world_currencies.dup
    end

    # Registered symbols sorted for detection: longest match wins, then parser priority.
    #
    # @return [Array<Array<String, Currency>>] sorted symbol-to-currency mappings
    # @api private
    def self.currency_symbols
      @currency_symbols ||= begin
        currencies.values
                  .reject { |currency| currency.symbol.empty? }
                  .map { |currency| [currency.symbol, currency] }
                  .sort_by { |symbol, currency| [-symbol.length, -currency.priority] }
      end.freeze
    end

    # Clears and refreshes the currency symbol cache.
    # Called when currencies are registered.
    #
    # @api private
    def self.invalidate_symbols_cache
      @currency_symbols = nil
    end
  end
end

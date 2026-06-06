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
      @currencies ||= begin
        registry = { 'XXX' => Currency.new(code: 'XXX', name: 'No currency', symbol: '¤') }
        load_currencies(registry)
      end
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

    # Loads currencies from YAML file into the registry.
    #
    # @param registry [Hash] the registry hash to populate
    # @return [Hash] the populated registry
    # @api private
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
end

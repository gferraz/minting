# frozen_string_literal: true

require 'yaml'

# Mint registry: manages all cached state
module Mint
  # Internal registry for currencies, symbols, and zero-money cache.
  # All mutable shared state lives here.
  module Registry
    extend self

    MUTEX = Monitor.new

    private_constant :MUTEX

    # Loads ISO world currencies from YAML file.
    #
    # @return [Hash{String => Currency}] ISO-4217 world currencies mapped by code
    # @api private
    def world_currencies
      @world_currencies || MUTEX.synchronize do
        @world_currencies = begin
          path = File.join(File.expand_path('../../data', __dir__), 'world-currencies.yaml')
          YAML.load_file(path).to_h { |entry| [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))] }
        end.freeze
      end
    end

    # Returns the frozen hash of all registered currencies (world + custom).
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def currencies
      @currencies || MUTEX.synchronize { @currencies = world_currencies.dup.freeze }
    end

    # Looks up a currency by its display symbol.
    #
    # @param symbol [String] the display symbol (e.g. "$", "R$")
    # @return [Currency, nil] the highest-priority currency for the symbol
    # @api private
    def currency_for_symbol(symbol)
      @currency_symbol_map || MUTEX.synchronize { @currency_symbol_map = currency_symbols.to_h.freeze }
      @currency_symbol_map[symbol]
    end

    # Scans +input+ for registered currency symbols and returns the first match.
    #
    # @param input [String] the string to scan
    # @return [Currency, nil]
    # @api private
    def detect_currency(input)
      currency_symbols.each do |symbol, currency|
        return currency if input.include?(symbol)
      end
      nil
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
        @currency_symbol_map = nil
        currency
      end
    end

    # Returns the cached zero-Money for a currency, creating it if needed.
    #
    # @param currency [Currency] the currency object
    # @return [Money] a frozen zero-Money
    # @api private
    def zero_for(currency)
      MUTEX.synchronize do
        @zeros ||= {}
        @zeros[currency] ||= Mint::Money.send(:new, 0, currency)
      end
    end

    private

    # Registered symbols sorted for detection: longest match wins, then parser priority.
    # Duplicate symbols are deduplicated — the highest-priority currency wins.
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
                    .uniq { |symbol, _| symbol }
                    .freeze
      end
    end
  end
end

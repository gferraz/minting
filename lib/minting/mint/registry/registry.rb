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
      @world_currencies ||= begin
        path = File.join(File.expand_path('../../data', __dir__), 'world-currencies.yaml')
        YAML.load_file(path).to_h { |entry| [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))] }
      end.freeze
    end

    # Returns the frozen hash of all registered currencies (world + custom).
    #
    # @return [Hash{String => Currency}] registered currencies mapped by code
    # @api private
    def currencies
      @currencies || MUTEX.synchronize { @currencies = world_currencies.dup.freeze }
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
  end
end

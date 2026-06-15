# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    extend self

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

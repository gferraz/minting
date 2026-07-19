# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    extend self

    def currency_for_symbol(symbol)
      sync_symbols
      @symbols_map[symbol]
    end

    def symbol_shared?(symbol)
      sync_symbols
      @shared_symbols.include?(symbol)
    end

    def detect_currency(input)
      sync_symbols
      input.match(@symbols_regex) { |m| @symbols_map[m[0]] }
    end

    private

    def build_symbol_regex(symbols)
      /(?<![a-zA-Z])#{Regexp.union(symbols)}(?![a-zA-Z])/
    end

    def sync_symbols
      MUTEX.synchronize do
        return if @symbols_list

        symbols_list = []
        currencies.each_value do |currency|
          next unless currency.symbol

          symbols_list << [currency.symbol, currency]
          symbols_list << [currency.disambiguate_symbol, currency] if currency.disambiguate_symbol
        end

        @shared_symbols = symbols_list.map(&:first).tally
                                      .select { |_, count| count > 1 }
                                      .keys
                                      .to_set
                                      .freeze

        symbols_list.sort_by! { |sym, cur| [-sym.length, -cur.priority] }
        symbols_list.uniq! { |sym, _| sym }

        @symbols_list  = symbols_list.freeze
        @symbols_map   = symbols_list.to_h.freeze
        @symbols_regex = build_symbol_regex(@symbols_map.keys)
      end
    end
  end
end

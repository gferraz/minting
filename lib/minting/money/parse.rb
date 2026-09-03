# frozen_string_literal: true

require_relative 'parse/separator_parser'

module Mint
  # :nodoc:
  class Money
    # Parses a human-readable money string into a {Money} object.
    #
    # Returns +nil+ when the input is invalid or currency cannot be determined.
    #
    # @param input [String] Amount input, optionally including a currency symbol or code
    # @param positional_currency [String, Currency, nil] deprecated positional
    #   fallback currency when none is present in +input+
    # @param default_currency [String, Currency, nil] fallback currency when none is present in +input+
    #   An embedded currency code or symbol takes precedence over this argument.
    #   The positional form is deprecated; use +default_currency:+ instead.
    # @param decimal [String, nil] decimal separator used by the input source.
    #   When omitted, it is inferred from +thousand:+ or separator positions.
    # @param thousand [String, nil] thousands separator used by the input source.
    #   When omitted, it is inferred from +decimal:+ or separator positions.
    # @return [Money, nil]
    #
    # @example With explicit currency
    #   Money.parse('19.99', 'USD')    #=> [USD 19.99]
    #   Money.parse('garbage', 'USD')  #=> nil
    #
    # @example With symbol or code in the string
    #   Money.parse('$19.99')            #=> [USD 19.99]
    #   Money.parse('USD 1,234.56')    #=> [USD 1234.56]
    #   Money.parse('123,456', 'EUR', decimal: ',') #=> [EUR 123.46]
    #   Money.parse('123,456', 'USD', thousand: ',') #=> [USD 123456.00]
    # @deprecated Pass the fallback currency as +default_currency:+.
    def self.parse(input, positional_currency = nil, default_currency: nil, decimal: nil, thousand: nil)
      if positional_currency
        warn 'DEPRECATION: Money.parse positional currency is deprecated; use default_currency: instead.', uplevel: 1
      end
      return nil unless input.is_a?(String)

      input = input.strip
      return nil if input.empty?

      currency = default_currency || positional_currency
      currency = parse_currency(input, currency)
      return nil unless currency

      amount = parse_amount(input, currency, decimal:, thousand:)
      return nil unless amount

      amount = currency.normalize_amount(amount)
      amount.zero? ? currency.zero : new(amount, currency)
    end

    # Like {.parse} but raises on failure.
    #
    # @param input [String] Amount input, optionally including a currency symbol or code
    # @param positional_currency [String, Currency, nil] deprecated positional
    #   fallback currency when none is present in +input+
    # @param default_currency [String, Currency, nil] fallback currency when none is present in +input+
    #   An embedded currency code or symbol takes precedence over this argument.
    #   The positional form is deprecated; use +default_currency:+ instead.
    # @param decimal [String, nil] decimal separator used by the input source.
    #   When omitted, it is inferred from +thousand:+ or separator positions.
    # @param thousand [String, nil] thousands separator used by the input source.
    #   When omitted, it is inferred from +decimal:+ or separator positions.
    # @return [Money]
    # @raise [ArgumentError] when +input+ is invalid or currency cannot be determined
    #
    # @example
    #   Money.parse!('19.99', 'USD')    #=> [USD 19.99]
    #   Money.parse!('garbage', 'USD')  #=> ArgumentError
    # @deprecated Pass the fallback currency as +default_currency:+.
    def self.parse!(input, positional_currency = nil, default_currency: nil, decimal: nil, thousand: nil)
      if positional_currency
        warn 'DEPRECATION: Money.parse! positional currency is deprecated; use default_currency: instead.', uplevel: 1
      end
      raise ArgumentError, 'input must be a String' unless input.is_a?(String)

      input = input.strip
      raise ArgumentError, 'input cannot be empty' if input.empty?

      currency = default_currency || positional_currency
      currency = parse_currency(input, currency)
      raise ArgumentError, "Currency [#{currency}] not found" unless currency

      amount = parse_amount(input, currency, decimal:, thousand:)
      raise ArgumentError, "Could not parse [#{input}]" unless amount

      amount = currency.normalize_amount(amount)
      amount.zero? ? currency.zero : new(amount, currency)
    end

    class << self
      private

      # Extracts one valid numeric value, allowing surrounding currency markers
      # and uppercase annotation words (for example, "MAX 10.00 USD").
      def parse_amount(input, currency, decimal: nil, thousand: nil)
        accounting_negative = input.start_with?('(') && input.end_with?(')')
        return nil if (input.include?('(') || input.include?(')')) && !accounting_negative

        numeric_input = accounting_negative ? input[1...-1] : input
        numeric_input = remove_currency_markers(numeric_input, currency)
        numeric_input = numeric_input.gsub(/\b[A-Z_]+\b/, ' ').delete('[]').strip
        numeric_input.sub!(/\A([+-])\s+/, '\\1')
        return nil unless numeric_input.match?(/\A[+-]?\d[\d.,]*\z/)

        numeric = parse_separators(numeric_input, decimal:, thousand:)
        return nil unless numeric

        amount = Rational(numeric)
        accounting_negative ? -amount : amount
      end

      def remove_currency_markers(input, currency)
        markers = [currency.symbol, currency.disambiguate_symbol].compact.uniq
        markers.reduce(input) { |result, marker| result.gsub(marker, ' ') }
      end

      # Extracts currency from a string by matching ISO code or symbol.
      #
      # Scans all uppercase words and returns the first registered code, falling
      # back to symbol matching. This correctly handles inputs like
      # "MAX 10.00 USD" where the first uppercase word isn't a currency code.
      def parse_currency(input, currency = nil)
        input.scan(/\b([A-Z_]+)\b/) do |(code)|
          found = Currency.for_code(code)
          return found if found
        end

        found = Registry.detect_currency(input)
        return found if found

        Currency.resolve(currency)
      end

      # Converts decimal/thousand separators into a plain decimal string.
      # An explicit decimal separator resolves otherwise ambiguous values.
      def parse_separators(numeric, decimal: nil, thousand: nil)
        return SeparatorParser.parse(numeric, decimal, thousand) if decimal || thousand

        parse_heuristic_separators(numeric)
      end

      def parse_heuristic_separators(numeric)
        return nil unless numeric.match?(/\d/)
        return nil unless valid_numeric_syntax?(numeric)

        case classify_separators(numeric)
        when :decimal_period   then numeric
        when :decimal_comma    then numeric.tr(',', '.')
        when :thousands_comma  then numeric.delete(',')
        when :thousands        then numeric.delete('.,')
        when :invalid          then nil
        when :mixed
          if numeric.rindex(',') > numeric.rindex('.')
            numeric.delete('.').tr(',', '.')
          else
            numeric.delete(',')
          end
        end
      end

      # Classifies the separator pattern in a numeric string.
      def classify_separators(numeric)
        case [numeric.count('.'), numeric.count(',')]
        in [0, 1] if numeric[-4] == ',' then :thousands_comma
        in [0, 1]                       then :decimal_comma
        in [0, 0] | [1, 0]              then :decimal_period
        in [p, c] if p > 1 && c > 1     then :invalid
        in [p, c] if p > 0 && c > 0     then :mixed
        else                                 :thousands
        end
      end

      def valid_numeric_syntax?(numeric)
        unsigned = numeric.delete_prefix('-').delete_prefix('+')
        unsigned.match?(/\A\d+\z/) ||
          unsigned.match?(/\A\d+[.,]\d+\z/) ||
          unsigned.match?(/\A\d+(?:,\d{3})+\.\d+\z/) ||
          unsigned.match?(/\A\d+(?:\.\d{3})+,\d+\z/) ||
          unsigned.match?(/\A\d+(?:,\d{3})+\z/) ||
          unsigned.match?(/\A\d+(?:\.\d{3})+\z/)
      end
    end
  end
end

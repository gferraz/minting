module Mint
  # nodoc
  class Money
    # Parses a human-readable money string into a {Money} object.
    #
    # @param input [String] Amount input, optionally including a currency symbol or code
    # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
    # @return [Money]
    # @raise [ArgumentError] when +input+ is invalid or currency cannot be determined
    #
    # @example With explicit currency
    #   Money.parse('19.99', 'USD')    #=> [USD 19.99]
    #   Money.parse('1.234,56', 'EUR') #=> [EUR 1234.56]
    #
    # @example With symbol or code in the string
    #   Money.parse('$19.99')            #=> [USD 19.99]
    #   Money.parse('19,99 €')         #=> [EUR 19.99]
    #   Money.parse('USD 1,234.56')    #=> [USD 1234.56]
    def self.parse(input, currency = nil)
      raise ArgumentError, 'input must be a String' unless input.is_a?(String)

      input = input.strip
      raise ArgumentError, 'input cannot be empty' if input.empty?

      if currency
        currency = Mint.currency(currency)
        unless currency
          raise ArgumentError,
                "Currency [#{currency}] not registered. Check Mint.currencies"
        end
      else
        currency = parse_currency(input)
      end

      amount = parse_amount(input)
      new(amount, currency)
    end

    # Extracts a numeric value from input that should only contain an amount.
    def self.parse_amount(input)
      # Remove any charater that is not a digit, comma or period
      numeric = input.scan(/[\d.\-,]/).join
      numeric = normalize_separators(numeric)
      Rational(numeric)
    end

    # Converts locale-specific decimal/thousand separators into a plain decimal string.
    def self.normalize_separators(numeric)
      case [numeric.count(','), numeric.count('.')]
      in [0, 0] | [0, 1] # Nothing to normalize (e.g. "1500" or "34.21").
        numeric
      in [1, 0] # Only one comma: decimal (e.g. 19,99 or 1,234).
        numeric.tr(',', '.')
      in [c, p] if c > 1 && p > 1 # Both separators appear multiple times
        raise ArgumentError, "could not distinguish decimal and thousand separators in '#{numeric}'"
      in [c, p] if c > 0 && p > 0 # Commas and dots: the rightmost one is the decimal separator.
        if numeric.rindex(',') > numeric.rindex('.')
          numeric.delete('.').tr(',', '.')
        else
          numeric.delete(',')
        end
      else # Multiple of the same separator only (e.g. 1,234,567) — all are thousands.
        numeric.delete(',.')
      end
    end

    def self.parse_currency(input)
      # Prefer an explicit ISO 4217 code (e.g. "USD 1,234.56") over symbol matching.
      code = input[/\b([A-Z]{3})\b/, 1]
      if code
        currency = Mint.currency(code)
        return currency if currency
      end

      # Fall back to registered symbols, longest first (HK$ before $).
      symbol_index.each do |symbol, currency|
        next if symbol.empty?

        return currency if input.include?(symbol)
      end

      raise ArgumentError,
            'currency could not be detected; pass a currency code as the second argument'
    end

    # Registered symbols sorted for detection: longest match wins, then parser priority.
    def self.symbol_index
      @symbol_index ||= Mint.currencies.values
                            .map { |c| [c.symbol, c] }
                            .reject { |symbol, _| symbol.empty? }
                            .sort_by do |symbol, currency|
                              [-symbol.length, -currency.priority, currency.code]
                            end
      @symbol_index
    end

    private_class_method :parse_amount, :normalize_separators,
                         :parse_currency,
                         :symbol_index
  end
end

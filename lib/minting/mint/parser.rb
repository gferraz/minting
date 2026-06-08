# frozen_string_literal: true

module Mint
  extend self

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
  def parse(input, currency = nil)
    raise ArgumentError, 'input must be a String' unless input.is_a?(String)

    input = input.strip
    raise ArgumentError, 'input cannot be empty' if input.empty?

    currency = Mint.currency(currency) || parse_currency(input)
    raise ArgumentError, "Currency [#{currency}] not registered" unless currency

    amount = currency.normalize_amount(parse_amount(input))
    Mint::Money.new(amount, currency)
  end

  private

  # Extracts a numeric value from input that should only contain an amount.
  def parse_amount(input)
    # Remove any charater that is not a digit, comma or period
    numeric = input.scan(/[\d.,-]/).join
    numeric = normalize_separators(numeric)
    Rational(numeric)
  end

  # Converts locale-specific decimal/thousand separators into a plain decimal string.
  def normalize_separators(numeric)
    case [numeric.count(','), numeric.count('.')]
    in [0, 0] | [0, 1] then numeric              # Nothing to normalize (e.g. "1500" or "34.21").
    in [1, 0]          then numeric.tr(',', '.') # Only one comma: decimal (e.g. 19,99 or 1,234).
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

  def parse_currency(input)
    case input
    when nil then return nil
    when String
      # Prefer an explicit ISO 4217 code (e.g. "USD 1,234.56") over symbol matching.
      currency = Mint.currency(input[/\b([A-Z_]+)\b/, 1])
      return currency if currency

      # Fall back to registered symbols, longest first (HK$ before $).
      Mint.currency_symbols.each do |symbol, currency|
        return currency if input.include?(symbol)
      end
    end
    raise ArgumentError, 'Currency could not be detected'
  end
end

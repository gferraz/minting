# frozen_string_literal: true

# Mint Money parsing
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

  def parse_currency(input)
    case input
    when String
      # Prefer an explicit ISO 4217 code (e.g. "USD 1,234.56") over symbol matching.
      currency = Mint.currency(input[/\b([A-Z_]+)\b/, 1])
      return currency if currency

      # Fall back to registered symbols, longest first (HK$ before $).
      CurrencyRegistry.currency_symbols.each do |symbol, currency|
        return currency if input.include?(symbol)
      end
    end
    raise ArgumentError, 'Currency could not be detected'
  end
end

# frozen_string_literal: true

# Mint Money parsing
module Mint
  extend self

  # Parses a human-readable money string into a {Money} object.
  #
  # Returns +nil+ when the input is invalid or currency cannot be determined.
  #
  # @param input [String] Amount input, optionally including a currency symbol or code
  # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
  # @return [Money, nil]
  #
  # @example With explicit currency
  #   Mint.parse('19.99', 'USD')    #=> [USD 19.99]
  #   Mint.parse('garbage', 'USD')  #=> nil
  #
  # @example With symbol or code in the string
  #   Mint.parse('$19.99')            #=> [USD 19.99]
  #   Mint.parse('USD 1,234.56')    #=> [USD 1234.56]
  def parse(input, currency = nil)
    return nil unless input.is_a?(String)

    input = input.strip
    return nil if input.empty?

    currency = parse_currency(input, currency)
    return nil unless currency

    amount = parse_amount(input)
    return nil unless amount

    amount = currency.normalize_amount(amount)
    Mint::Money.new(amount, currency)
  end

  # Like {.parse} but raises on failure.
  #
  # @param input [String] Amount input, optionally including a currency symbol or code
  # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
  # @return [Money]
  # @raise [ArgumentError] when +input+ is invalid or currency cannot be determined
  #
  # @example
  #   Mint.parse!('19.99', 'USD')    #=> [USD 19.99]
  #   Mint.parse!('garbage', 'USD')  #=> ArgumentError
  def parse!(input, currency = nil)
    raise ArgumentError, 'input must be a String' unless input.is_a?(String)

    input = input.strip
    raise ArgumentError, 'input cannot be empty' if input.empty?

    currency = parse_currency(input, currency)
    raise ArgumentError, "Currency [#{currency}] not found" unless currency

    amount = parse_amount(input)
    raise ArgumentError, "Could not parse [#{input}]" unless amount

    amount = currency.normalize_amount(amount)
    Mint::Money.new(amount, currency)
  end

  private

  # Extracts a numeric value from input that should only contain an amount.
  # @private
  def parse_amount(input)
    accounting_negative = input.start_with?('(') && input.end_with?(')')

    # Remove any charater that is not a digit, comma or period
    numeric_input = input.scan(/[\d.,-]/).join
    numeric = parse_separators(numeric_input)
    return nil unless numeric

    amount = Rational(numeric)
    accounting_negative ? -amount : amount
  end

  # Extracts currency from a string by matching ISO code or symbol.
  #
  # Scans all uppercase words and returns the first registered code, falling
  # back to symbol matching. This correctly handles inputs like
  # "MAX 10.00 USD" where the first uppercase word isn't a currency code.
  # @private
  def parse_currency(input, currency = nil)
    input.scan(/\b([A-Z_]+)\b/) do |(code)|
      found = Currency.for_code(code)
      return found if found
    end

    found = Registry.detect_currency(input)
    return found if found

    Currency.resolve(currency)
  end
end

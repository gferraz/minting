# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    private

    # Selects the appropriate format template and value based on the amount's sign.
    #
    # @param format [Hash] format hash with :positive, :negative, :zero keys
    # @return [Array(Symbol, Rational)] format template and amount to format
    def select_format(format)
      negative_format = format[:negative]
      zero_format = format[:zero]

      if amount.negative? && negative_format
        [negative_format, -amount]
      elsif amount.zero? && zero_format
        [zero_format,     amount]
      else
        [format[:positive], amount]
      end
    end

    # Validates that format hash contains only known keys.
    #
    # @param format [Hash] format hash to validate
    # @raise [ArgumentError] if unknown keys are present
    def validate_format_hash(format)
      unknown = format.keys - %i[positive negative zero]

      raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
    end

    # Applies a format template to produce a formatted string representation.
    #
    # @param format [Hash] format configuration
    # @return [String] formatted amount
    def format_amount(format)
      format, value = select_format(format)
      format ||= '%<symbol>s%<amount>f'
      # Automatically adjust decimal places based on currency subunit if missing
      format = format.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{currency.subunit}f")

      refs = format.scan(/%<(\w+)>/).flatten.map(&:to_sym)
      all_args = { amount: value, currency: currency_code, symbol: currency.symbol }
      Kernel.format(format, **all_args.slice(*refs))
    end
  end
end

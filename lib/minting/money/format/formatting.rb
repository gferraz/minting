# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    private

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

    def validate_format_hash(format)
      unknown = format.keys - %i[positive negative zero]

      raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
    end

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

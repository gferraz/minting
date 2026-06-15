# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    private

    # Resolves format/decimal/thousand from locale_backend when not explicitly given.
    # @private
    def resolve_locale_for(format, decimal, thousand)
      locale = locale_backend
      [format || locale[:format] || '%<symbol>s%<amount>f',
       decimal || locale[:decimal] || '.',
       thousand || locale[:thousand] || ',']
    end

    def locale_backend
      bk = Mint.locale_backend
      return {} unless bk.respond_to?(:call)

      bk.call
    end

    # Selects the appropriate format template and value based on the amount's sign.
    # @private
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
    # @private
    def validate_format_hash(format)
      unknown = format.keys - %i[positive negative zero]

      raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
    end

    # Applies a format template to produce a formatted string representation.
    # @private
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

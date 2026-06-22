# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    private

    # Resolves the format template and amount based on the amount's sign
    # (negative_format/zero_format may override both the template and negate the value)
    # @private
    def resolve_format(format)
      negative_format = format[:negative]
      zero_format = format[:zero]

      if amount.negative? && negative_format
        [negative_format, -amount]
      elsif amount.zero? && zero_format
        [zero_format,     amount]
      else
        [format[:positive] || '%<symbol>s%<amount>f', amount]
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
    #
    def format_amount(format, decimal:, thousand:)
      resolved_format, adjusted_amount = resolve_format(format)

      # Inject the currency's subunit precision into %<amount>f specifiers
      # e.g. '%<amount>f' becomes '%<amount>.2f' for USD
      resolved_format = resolved_format.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{currency.subunit}f")

      # Zero-subunit currencies (e.g. JPY) have no fractional part —
      # strip %<fractional>d specifiers entirely since there's no valid integer for "nothing"
      resolved_format.gsub!(/%<fractional>[^%]*?d/, '') if currency.subunit.zero?

      result = Kernel.format(resolved_format, {
                               amount: adjusted_amount,
                               currency: currency_code,
                               symbol: currency.symbol,
                               integral: adjusted_amount.to_i,
                               fractional: fractional
                             })

      # Substitute decimal first, while the dot is still unambiguous
      result.gsub!(/(?<=\d)\.(?=\d)/, decimal) if decimal != '.'

      # Apply thousands only to the integral portion, using the decimal as boundary
      if thousand && !thousand.empty? && adjusted_amount.abs >= 1000
        parts = result.split(/(?<=\d)#{Regexp.escape(decimal)}(?=\d)/, 2)
        parts[0].gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/, "\\1#{thousand}")
        result = parts.join(decimal)
      end

      result
    end
  end
end

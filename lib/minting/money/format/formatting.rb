# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    def self.format_cache
      @format_cache ||= {}
    end

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

    # Validates +decimal+ and +thousand+ separator arguments.
    # @private
    def validate_separators!(decimal:, thousand:)
      case decimal
      when nil      # :noop
      when ''       then raise ArgumentError, 'decimal must be a non-empty'
      when thousand then raise ArgumentError, "decimal and thousand cannot be identical: #{decimal.inspect}"
      when String   # :noop
      else raise ArgumentError, "decimal must be a String, false, or nil, got #{decimal.inspect}"
      end

      case thousand
      when false, nil, String # :noop
      else raise ArgumentError, "thousand must be a String, false, or nil, got #{thousand.inspect}"
      end
    end

    def apply_thousand_separator(string, decimal:, thousand:)
      return string if !thousand || thousand.empty?

      # Apply thousands only to the integral portion, using the decimal as boundary
      parts = string.split(/(?<=\d)#{Regexp.escape(decimal)}(?=\d)/, 2)
      parts[0].gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/, "\\1#{thousand}")
      parts.join(decimal)
    end

    # Applies a format template to produce a formatted string representation.
    # @private
    #
    def format_amount(format, decimal:, thousand:)
      subunit = currency.subunit
      resolved_format, adjusted_amount = resolve_format(format)

      resolved_format = inject_subunit_precision(resolved_format, subunit)

      result = Kernel.format(resolved_format, {
                               amount: adjusted_amount,
                               currency: currency_code,
                               symbol: currency.symbol,
                               integral: adjusted_amount.to_i,
                               fractional: fractional
                             })

      # Substitute decimal first, while the dot is still unambiguous
      result.gsub!(/(?<=\d)\.(?=\d)/, decimal) if decimal != '.'

      return result if adjusted_amount.abs < 1000

      # Apply thousands only to the integral portion, using the decimal as boundary
      apply_thousand_separator(result, decimal:, thousand:)
    end

    # Injects the currency's subunit precision into %<amount>f specifiers
    # (e.g. '%<amount>f' → '%<amount>.2f' for USD). For zero-subunit
    # currencies (e.g. JPY), strips %<fractional>d specifiers.
    # @private
    def inject_subunit_precision(template, subunit)
      Money.format_cache[[template, subunit]] ||= begin
        result = template.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{subunit}f")
        result.gsub!(/%<fractional>[^%]*?d/, '') if subunit.zero?
        result.freeze
      end
    end
  end
end

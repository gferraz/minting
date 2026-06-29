# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    def self.compiled_formatters
      @compiled_formatters ||= {}
    end

    # Build each sign template with subunit precision baked in, returning a
    # frozen Hash of templates keyed by sign (:positive, :negative, :zero).
    # Keeps %<symbol>s and %<currency>s as format args so width/padding specifiers work.
    # @private
    def self.compile_templates(format_hash, subunit)
      [
        format_hash[:positive] || '%<symbol>s%<amount>f',
        format_hash[:negative],
        format_hash[:zero]
      ].map do |sign_format|
        next unless sign_format

        # Injects the currency's subunit precision into %<amount>f specifiers
        # (e.g. '%<amount>f' → '%<amount>.2f' for USD), preserving any
        # existing width/alignment specifier (e.g. '%<amount>+10f' stays).
        sign_format = sign_format.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{subunit}f")

        # For zero-subunit currencies (JPY, KRW, etc.), strip %<fractional>d
        # specifiers entirely since there is no fractional part to display.
        sign_format.gsub!(/%<fractional>[^%]*?d/, '') if subunit.zero?

        sign_format
      end
    end

    # Builds and returns a lambda that formats amounts for a fixed
    # [format_config, currency, decimal, thousand] combination.
    # The lambda is cached by {.compiled_formatters}.
    # @private
    def self.compile_formatter(format_hash, currency, decimal, thousand) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      subunit = currency.subunit
      has_decimal_substitution = decimal != '.'
      escaped_decimal = Regexp.escape(decimal)
      has_thousand_separator = thousand && !thousand.empty?

      templates = compile_templates(format_hash, subunit)
      positive_template, negative_template, zero_template = templates

      # Detect whether templates use %<fractional>, and whether thousand separator
      # logic is needed (only when there is an amount or integral placeholder)
      all_templates = templates.join
      needs_fractional = all_templates.include?('%<fractional>')
      needs_integral = all_templates.include?('%<amount>') || all_templates.include?('%<integral>')

      lambda do |amount, cur|
        format_template, adjusted_amount =
          if negative_template && amount < 0
            [negative_template, -amount]
          elsif zero_template && amount == 0
            [zero_template, amount]
          else
            [positive_template, amount]
          end

        args = { amount: adjusted_amount,
                 symbol: cur.symbol,
                 currency: cur.code,
                 integral: adjusted_amount.to_i }

        args[:fractional] = ((amount.abs % 1) * cur.fractional_multiplier).to_i if needs_fractional

        result = Kernel.format(format_template, **args)
        result.gsub!(/(?<=\d)\.(?=\d)/, decimal) if has_decimal_substitution

        if needs_integral && has_thousand_separator && (adjusted_amount >= 1000 || adjusted_amount <= -1000)
          parts = result.split(/(?<=\d)#{escaped_decimal}(?=\d)/, 2)
          parts[0].gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/) { Regexp.last_match(1) + thousand }
          result = parts.join(decimal)
        end

        result
      end
    end

    private

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

    # Applies a format template to the money amount, returning a formatted string.
    # Uses a cached compiled formatter lambda that pre-resolves currency-specific
    # values (symbol, code, subunit) so per-call work is reduced to
    # Kernel.format + optional separator substitutions.
    # @private
    def format_amount(format, decimal:, thousand:)
      key = [format, currency_code, decimal, thousand].hash

      formatter = Money.compiled_formatters[key] ||= Money.compile_formatter(format, currency, decimal, thousand)

      formatter.call(amount, currency)
    end
  end
end

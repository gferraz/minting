# frozen_string_literal: true

module Mint
  class Money
    # Compiles and caches formatter lambdas for a fixed combination of format
    # template, currency, and separator configuration.
    #
    # Use {.for} to obtain a cached instance; avoid +new+ directly unless you
    # want an uncached formatter (typically only useful for testing).
    #
    # @api private
    class Formatter # rubocop:disable Metrics/ClassLength
      extend FormatterValidator

      def self.cache
        @cache ||= {}
      end

      # Returns a cached {Formatter} for the given configuration.
      # @param format [Hash{Symbol => String}] per-sign templates
      # @param decimal [String] decimal separator
      # @param thousand [String, false] thousands delimiter (+false+ disables)
      def self.for(format, decimal, thousand)
        decimal ||= '.'
        key = [format, decimal, thousand]
        formatter = cache[key]
        return formatter if formatter

        validate_format!(format)
        validate_separators!(decimal:, thousand:)

        cache[key] = new(format, decimal, thousand)
      end

      def initialize(format, decimal, thousand)
        @format = format
        @decimal = decimal
        @thousand = thousand
        compile
      end

      SUBUNIT_PLACEHOLDER = "\uE000"
      # Matches a digit followed by groups of exactly 3 digits that terminate
      # at a non-digit or end-of-string. Used to insert thousand separators.
      # e.g. "1234567" → "1" matches before "234" + "567" at string end.
      THOUSAND_RE = /(\d)(?=(?:\d{3})+(?:[^\d]|$))/

      def format(money)
        amount = money.amount
        currency = money.currency

        template = @templates[amount <=> 0] || @positive_template
        display_amount = template == @negative_template ? -amount : amount

        template = template.gsub(SUBUNIT_PLACEHOLDER, currency.subunit.to_s) if @has_placeholder
        result = Kernel.format(template,
                               currency: currency.code,
                               dsymbol: @needs_dsymbol && currency.dsymbol,
                               symbol: currency.symbol,
                               amount: display_amount,
                               integral: display_amount.to_i,
                               fractional: @needs_fractional ? money.fractional.abs : 0)
        apply_separators(result, display_amount)
      end

      private

      def apply_separators(result, display_amount)
        if @needs_thousand_substitution && (display_amount >= 1000 || display_amount <= -1000)
          apply_thousand_separators(result, display_amount)
        elsif @decimal != '.'
          replace_decimal_separators(result, display_amount)
        else
          result
        end
      end

      def apply_thousand_separators(result, display_amount)
        int_str = display_amount.abs.to_i.to_s
        found_dot = false
        search_start = 0
        loop do
          idx = result.index(int_str, search_start)
          break unless idx

          dot_pos = idx + int_str.length
          if dot_pos < result.length && result[dot_pos] == '.'
            found_dot = true
            int_part = result[idx...dot_pos].gsub(THOUSAND_RE, @thousand_replacement)
            result = "#{result[0...idx]}#{int_part}#{@decimal}#{result[(dot_pos + 1)..]}"
            search_start = idx + int_part.length + @decimal.length
          else
            int_part = int_str.gsub(THOUSAND_RE, @thousand_replacement)
            result = "#{result[0...idx]}#{int_part}#{result[dot_pos..]}"
            search_start = idx + int_part.length
          end
        end
        return result if found_dot

        # No decimal point found (e.g. %<integral>d) — apply thousand to whole string
        result.gsub(THOUSAND_RE, @thousand_replacement)
      end

      def replace_decimal_separators(result, display_amount)
        int_str = display_amount.abs.to_i.to_s
        search_start = 0
        loop do
          idx = result.index(int_str, search_start)
          break unless idx

          dot_pos = idx + int_str.length
          if dot_pos < result.length && result[dot_pos] == '.'
            result = "#{result[0...dot_pos]}#{@decimal}#{result[(dot_pos + 1)..]}"
            search_start = dot_pos + @decimal.length
          else
            search_start = idx + 1
          end
        end
        result
      end

      def compile_templates
        @templates = { -1 => @format[:negative], 0 => @format[:zero], 1 => @format[:positive] || Money::DEFAULT_FORMAT }
        @templates.compact!
        # Inject subunit precision into %<amount>f specs that lack an explicit
        # precision. Matches "%<amount>f" or "%+10<amount>f" (with optional
        # flags/width before the named ref) and appends a placeholder for the
        # currency subunit digits — e.g. "%<amount>f" → "%<amount>\uE000f".
        # The placeholder is later replaced with the actual subunit count at
        # format time (e.g. "\uE000" → "2" for USD, "0" for JPY).
        @templates.transform_values! { |f| f.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{SUBUNIT_PLACEHOLDER}f") }
        @negative_template = @templates[-1]
        @positive_template = @templates[1]
        @templates
      end

      def compile
        compile_templates
        templates_values = @templates.values
        joined_template = templates_values.join
        @has_placeholder = joined_template.include?(SUBUNIT_PLACEHOLDER)
        @needs_fractional = joined_template.include?('%<fractional>')
        @needs_dsymbol = joined_template.include?('%<dsymbol>')
        @needs_thousand_substitution = @thousand && !@thousand.empty? && (joined_template.include?('%<amount>') ||
                         joined_template.include?('%<integral>'))
        @thousand_replacement = "\\1#{@thousand}" if @needs_thousand_substitution
      end
    end
  end
end

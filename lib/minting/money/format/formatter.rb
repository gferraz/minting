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
    class Formatter
      extend FormatterValidator

      def self.cache = @cache ||= {}

      # Returns a cached {Formatter} for the given configuration.
      # @param format [Hash{Symbol => String}] per-sign templates
      # @param decimal [String] decimal separator
      # @param thousand [String, false] thousands delimiter (+false+ disables)
      def self.for(format, decimal, thousand)
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
        display_amount = template == @nx egative_template ? -amount : amount
        integral = display_amount.to_i

        template = template.gsub(SUBUNIT_PLACEHOLDER, currency.subunit.to_s) if @has_placeholder
        result = Kernel.format(template,
                               currency: currency.code,
                               dsymbol: @needs_dsymbol && currency.dsymbol,
                               symbol: currency.symbol,
                               amount: display_amount,
                               integral: integral,
                               fractional: @needs_fractional ? money.fractional.abs : 0)
        apply_separators(result, integral)
      end

      private

      def apply_separators(result, integral)
        unsigned_integral = integral.abs
        int_str = unsigned_integral.to_s

        result.sub!("#{int_str}.", "#{int_str}#{@decimal}") if @decimal != '.'

        if @needs_thousand_substitution && unsigned_integral >= 1000
          formatted_int = int_str.gsub(THOUSAND_RE, @thousand_replacement)
          result.gsub!(int_str, formatted_int)
        end
        result
      end

      def compile
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

        joined_template = @templates.values.join
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

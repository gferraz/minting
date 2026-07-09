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
      def self.cache
        @cache ||= {}
      end

      # Returns a cached {Formatter} for the given configuration.
      #
      # @param format [Hash{Symbol => String}] per-sign templates
      # @param decimal [String] decimal separator
      # @param thousand [String, false] thousands delimiter (+false+ disables)
      # @return [Formatter]
      def self.for(format, decimal, thousand)
        decimal ||= '.'
        key = [format, decimal, thousand].hash
        return cache[key] if cache.key?(key)

        validate_format!(format)
        validate_separators!(decimal:, thousand:)

        cache[key] = new(format, decimal, thousand)
      end

      def self.validate_format!(format)
        raise ArgumentError, 'template must not be empty' if format == {}

        unknown = format.keys - %i[positive negative zero]
        raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
      end

      def self.validate_separators!(decimal:, thousand:)
        case decimal
        when ''       then raise ArgumentError, "decimal separator must be a non-empty - #{decimal.inspect}"
        when /\d/     then raise ArgumentError, "decimal separator cannot be a numeral - #{decimal.inspect}"
        when thousand then raise ArgumentError, "decimal and thousand cannot be identical - #{decimal.inspect}"
        when String # :noop
        else raise ArgumentError, "decimal must be a String, false, or nil, got #{decimal.inspect}"
        end

        case thousand
        when false, nil # :noop
        when /\d/ then raise ArgumentError, "decimal separator cannot be a numeral - #{decimal.inspect}"
        when String # :noop
        else raise ArgumentError, "thousand must be a String, false, or nil, got #{thousand.inspect}"
        end
      end

      def initialize(format, decimal, thousand)
        @format = format
        @decimal = decimal
        @thousand = thousand
        compile
      end

      SUBUNIT_PLACEHOLDER = "\uE000"
      THOUSAND_RE = /(\d)(?=(?:\d{3})+(?:[^\d]|$))/
      DECIMAL_DOT_RE = /(?<=\d)\.(?=\d)/

      def format(money)
        amount = money.amount
        currency = money.currency
        symbol = currency.symbol

        template = @templates[amount <=> 0] || @positive_template
        display_amount = template == @negative_template ? -amount : amount

        template = template.gsub(SUBUNIT_PLACEHOLDER, currency.subunit.to_s) if @has_placeholder
        result = Kernel.format(template,
                               currency: currency.code,
                               dsymbol: currency.disambiguate_symbol || symbol,
                               symbol: symbol,
                               amount: display_amount,
                               integral: display_amount.to_i,
                               fractional: @needs_fractional ? money.fractional.abs : 0)
        apply_separators(result, amount)
      end

      private

      def apply_separators(result, original_amount)
        result = result.gsub(DECIMAL_DOT_RE, @decimal) if @decimal != '.'

        if @needs_thousand_substitution && (original_amount >= 1000 || original_amount <= -1000)
          parts = result.split(@split_regex, 2)
          parts[0].gsub!(THOUSAND_RE, @thousand_replacement)
          result = parts.join(@decimal)
        end

        result
      end

      def compile_templates
        format_templates = [@format[:negative], @format[:zero], @format[:positive] || Money::DEFAULT_FORMAT]
        format_templates.map! do |sign_format|
          # Inject placeholder for subunit precision into %<amount>f (replaced with actual at call time)
          sign_format = sign_format&.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{SUBUNIT_PLACEHOLDER}f")
          sign_format.freeze
        end

        @negative_template, @zero_template, @positive_template = format_templates
        @templates = { -1 => @negative_template, 0 => @zero_template, 1 => @positive_template }.freeze
        format_templates
      end

      def compile
        templates_values = compile_templates
        joined_template = templates_values.join

        @split_regex = /(?<=\d)#{Regexp.escape(@decimal)}(?=\d)/
        @has_placeholder = joined_template.include?(SUBUNIT_PLACEHOLDER)
        @needs_fractional = joined_template.include?('%<fractional>')
        @needs_thousand_substitution = @thousand && !@thousand.empty? && (joined_template.include?('%<amount>') ||
                         joined_template.include?('%<integral>'))
        @thousand_replacement = "\\1#{@thousand}" if @needs_thousand_substitution
      end
    end
  end
end

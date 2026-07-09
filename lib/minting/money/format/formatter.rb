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
      # @param currency [Currency] the target currency
      # @param decimal [String] decimal separator
      # @param thousand [String, false] thousands delimiter (+false+ disables)
      # @return [Formatter]
      def self.for(format, currency, decimal, thousand)
        decimal ||= '.'
        key = [format, currency.code, decimal, thousand].hash
        return cache[key] if cache.key?(key)

        validate_format!(format)
        validate_separators!(decimal:, thousand:)

        cache[key] = new(format, currency, decimal, thousand)
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

      def initialize(format, currency, decimal, thousand)
        @format = format
        @currency = currency
        @decimal = decimal
        @thousand = thousand
        compile!
      end

      # Formats +amount+ using the configured template and separators.
      #
      # @param amount [Rational] the monetary amount
      # @return [String]
      def format(amount)
        template, display_amount = resolve_template(amount)
        result = Kernel.format(template, **build_args(display_amount))
        apply_separators(result, amount)
      end

      private

      def resolve_template(amount)
        if @negative_template && amount < 0
          [@negative_template, -amount]
        elsif @zero_template && amount == 0
          [@zero_template, amount]
        else
          [@positive_template, amount]
        end
      end

      def build_args(amount)
        args = @template_args.dup
        args[:amount] = amount
        args[:integral] = amount.to_i
        args[:fractional] = ((amount.abs % 1) * @multiplier).to_i if @needs_fractional
        args
      end

      def apply_separators(result, original_amount)
        # Replace the decimal point inserted by Kernel.format with the locale's decimal separator
        result = result.gsub(/(?<=\d)\.(?=\d)/, @decimal) if @needs_decimal_substitution

        if @needs_thousand_substitution && (original_amount >= 1000 || original_amount <= -1000)
          # Split on the decimal separator between digits only (symbols may contain '.' e.g. د.إ)
          parts = result.split(/(?<=\d)#{@escaped_decimal}(?=\d)/, 2)
          # Insert thousand separator before groups of 3 digits in the integral part
          parts[0].gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/) { Regexp.last_match(1) + @thousand }
          result = parts.join(@decimal)
        end

        result
      end

      def compile_templates
        subunit = @currency.subunit

        [@format[:positive] || Money::DEFAULT_FORMAT, @format[:negative], @format[:zero]].map do |sign_format|
          next unless sign_format

          # Inject subunit precision into %<amount>f (e.g. → %<amount>.2f)
          sign_format = sign_format.gsub(/%<amount>(\s*\+?\d*)f/, "%<amount>\\1.#{subunit}f")

          # Strip %<fractional>d entirely for zero-subunit currencies (JPY, KRW…)
          sign_format.gsub!(/%<fractional>[^%]*?d/, '') if subunit.zero?
          sign_format
        end
      end

      def compile!
        @escaped_decimal = Regexp.escape(@decimal)
        @positive_template, @negative_template, @zero_template = templates = compile_templates

        @needs_decimal_substitution = @decimal != '.'

        joined_template = templates.join
        @needs_fractional = joined_template.include?('%<fractional>')

        @needs_thousand_substitution = @thousand &&
                                       !@thousand.empty? &&
                                       (joined_template.include?('%<amount>') || joined_template.include?('%<integral>'))

        @multiplier = @currency.fractional_multiplier

        @template_args = {
          currency: @currency.code,
          dsymbol: @currency.disambiguate_symbol || @currency.symbol,
          symbol: @currency.symbol
        }.freeze
      end
    end
  end
end

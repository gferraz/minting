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
      # Named format presets. Each preset is a format template with optional
      # +:decimal+, +:thousand+ defaults.
      #
      # @example
      #   Money::Formatter::PRESETS[:accounting]
      #   #=> { format: { negative: '(%<symbol>s%<amount>f)' } }
      #
      # @return [Hash{Symbol => Hash{Symbol => Object}}]
      PRESETS = {
        amount: { format: '%<amount>f' },
        accounting: { format: { negative: '(%<symbol>s%<amount>f)' } },
        european: { format: '%<amount>f %<symbol>s', decimal: ',', thousand: '.' },
        currency: { format: '%<currency>s %<amount>f' }
      }.freeze

      # Returns a cached {Formatter} for the named preset merged with any
      # +**overrides+.
      #
      # @param name [Symbol] preset name (+:accounting+, +:european+, …)
      # @param currency [Currency] the target currency
      # @param overrides [Hash] optional overrides (+:format+, +:decimal+,
      #   +:thousand+) that take precedence over the preset defaults
      # @return [Formatter]
      # @raise [ArgumentError] if +name+ is not a recognised preset
      def self.named(name, currency, **overrides)
        config = PRESETS.fetch(name) { raise ArgumentError, "Unknown format preset: #{name.inspect}" }

        format   = overrides.fetch(:format, config[:format])
        decimal  = overrides.fetch(:decimal, config.fetch(:decimal, '.'))
        thousand = overrides.fetch(:thousand, config.fetch(:thousand, ','))

        format_hash = case format
                      when Hash   then format
                      when String then { positive: format }
                      when nil    then { positive: Money::DEFAULT_FORMAT }
                      else raise ArgumentError, "Invalid format: #{format.inspect}"
                      end

        Money::Formatter.for(format_hash, currency, decimal, thousand)
      end

      def self.cache
        @cache ||= {}
      end

      # Returns a cached {Formatter} for the given configuration.
      #
      # @param format [Hash{Symbol => String}] per-sign templates
      # @param currency [Currency] the target currency
      # @param decimal [String] decimal separator
      # @param thousand [String, nil] thousands delimiter (+nil+ disables)
      # @return [Formatter]
      def self.for(format, currency, decimal, thousand)
        key = [format, currency.code, decimal, thousand].hash
        cache[key] ||= new(format, currency, decimal, thousand)
      end

      def initialize(format, currency, decimal, thousand)
        @format = format
        @currency = currency
        @decimal = decimal
        @thousand = thousand
        @compiled_formatter = nil
      end

      # Formats +amount+ using the configured template and separators.
      #
      # @param amount [Rational] the monetary amount
      # @return [String]
      def call(amount)
        @compiled_formatter ||= compile_formatter
        @compiled_formatter.call(amount)
      end

      private

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

      def compile_formatter # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        has_decimal_substitution = @decimal != '.'
        escaped_decimal = Regexp.escape(@decimal)
        has_thousand_separator = @thousand && !@thousand.empty?

        all_templates = compile_templates
        positive_template, negative_template, zero_template = all_templates

        templates = all_templates.compact.join
        needs_fractional = templates.include?('%<fractional>')
        needs_integral = templates.include?('%<amount>') || templates.include?('%<integral>')
        multiplier = @currency.fractional_multiplier
        symbol = @currency.symbol

        template_args = {
          currency: @currency.code,
          dsymbol: @currency.disambiguate_symbol || symbol,
          symbol: symbol
        }.freeze

        decimal = @decimal
        thousand = @thousand

        lambda do |amount|
          format_template = if negative_template && amount < 0
                              amount = -amount
                              negative_template
                            elsif zero_template && amount == 0
                              zero_template
                            else
                              positive_template
                            end

          args = template_args.dup
          args[:amount] = amount
          args[:integral] = amount.to_i
          args[:fractional] = ((amount.abs % 1) * multiplier).to_i if needs_fractional

          result = Kernel.format(format_template, **args)

          # Replace the decimal point inserted by Kernel.format with the locale's decimal separator
          result.gsub!(/(?<=\d)\.(?=\d)/, decimal) if has_decimal_substitution

          if needs_integral && has_thousand_separator && (amount >= 1000 || amount <= -1000)
            # Split on the decimal separator between digits only (symbols may contain '.' e.g. د.إ)
            parts = result.split(/(?<=\d)#{escaped_decimal}(?=\d)/, 2)
            # Insert thousand separator before groups of 3 digits in the integral part
            parts[0].gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]|$))/) { Regexp.last_match(1) + thousand }
            result = parts.join(decimal)
          end

          result
        end
      end
    end
  end
end

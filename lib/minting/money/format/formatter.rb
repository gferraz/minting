# frozen_string_literal: true

require 'monitor'

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

      # Keep enough compiled configurations for typical application presets and
      # locales without retaining every caller-provided template indefinitely.
      CACHE_LIMIT = 256
      CACHE_MUTEX = Monitor.new

      private_constant :CACHE_MUTEX

      @cache = {}.freeze

      class << self
        attr_reader :cache
      end

      # Returns a cached {Formatter} for the given configuration. The cache is
      # thread-safe and bounded by {CACHE_LIMIT}; once full, new configurations
      # are compiled without being retained.
      # @param format [Hash{Symbol => String}] per-sign templates
      # @param decimal [String] decimal separator
      # @param thousand [String, false] thousands delimiter (+false+ disables)
      def self.for(format, decimal, thousand)
        key = [format, decimal, thousand]
        formatter = cache[key]
        return formatter if formatter

        CACHE_MUTEX.synchronize do
          formatter = cache[key]
          return formatter if formatter

          validate_format!(format)
          validate_separators!(decimal:, thousand:)

          formatter = new(format, decimal, thousand)
          @cache = cache.merge(key => formatter).freeze unless cache.size >= CACHE_LIMIT
          formatter
        end
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

        templates = @has_placeholder ? @templates_by_subunit[currency.subunit] : @templates

        template = templates[amount <=> 0] || templates[1]

        display_amount = @has_negative_template && amount < 0 ? -amount : amount
        integral = display_amount.to_i

        sign = if amount.negative?
                 '-'
               elsif amount.positive?
                 '+'
               else
                 ''
               end

        result = Kernel.format(template,
                               currency: currency.code,
                               dsymbol: @needs_dsymbol && currency.dsymbol,
                               symbol: currency.symbol,
                               amount: display_amount,
                               magnitude: amount.abs,
                               sign:,
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
        # Inject subunit precision into amount and magnitude f specs that lack
        # an explicit precision. Matches "%<amount>f" or "%<magnitude>f" and
        # appends a placeholder for the currency subunit digits.
        # The placeholder is later replaced with the actual subunit count at
        # format time (e.g. "\uE000" → "2" for USD, "0" for JPY).
        @templates.transform_values! do |f|
          f.gsub(/%<(amount|magnitude)>(\s*\+?\d*)f/, "%<\\1>\\2.#{SUBUNIT_PLACEHOLDER}f")
        end
        @has_negative_template = @templates.key?(-1)

        joined = @templates.values.join
        @needs_fractional = joined.include?('%<fractional>')
        @needs_dsymbol = joined.include?('%<dsymbol>')

        @needs_thousand_substitution = @thousand && !@thousand.empty? &&
                                       (joined.include?('%<amount>') ||
                                        joined.include?('%<magnitude>') ||
                                        joined.include?('%<integral>'))
        @thousand_replacement = "\\1#{@thousand}" if @needs_thousand_substitution

        @has_placeholder = joined.include?(SUBUNIT_PLACEHOLDER)
        return unless @has_placeholder

        @templates_by_subunit = Hash.new do |h, subunit|
          h[subunit] = @templates.transform_values { |f| f.gsub(SUBUNIT_PLACEHOLDER, subunit.to_s) }
        end
      end
    end
  end
end

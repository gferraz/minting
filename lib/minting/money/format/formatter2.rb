# frozen_string_literal: true

module Mint
  class Money
    # Formatter that pre-formats numeric values with correct separators
    # before embedding them in the template, avoiding fragile post-processing
    # regex on the full Kernel.format output.
    #
    # @api private
    class Formatter2 # rubocop:disable Metrics/ClassLength
      extend FormatterValidator

      def self.cache
        @cache ||= {}
      end

      def self.for(format, decimal, thousand)
        decimal ||= '.'
        key = [format, decimal, thousand].hash
        return cache[key] if cache.key?(key)

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

      AMOUNT_PH_BASE = "\uE001"
      INTEGRAL_PH_BASE = "\uE002"
      TEMPLATE_DOT_PH = "\uE003"
      AMOUNT_SPEC_RE = /%(?:([-+ 0#]*\d*)(?:\.(\d*))?<amount>|<amount>([-+ 0#]*\d*)(?:\.(\d*))?)([fd])/
      INTEGRAL_SPEC_RE = /%(?:([-+ 0#]*\d*)<integral>|<integral>([-+ 0#]*\d*))(d)/
      SPEC_PARTS_RE = /^([-+ 0#]*)(\d*)(?:\.(\d*))?$/
      THOUSAND_RE = /(\d)(?=(?:\d{3})+(?:[^\d]|$))/

      def format(money)
        amount = money.amount
        currency = money.currency
        template = @templates[amount <=> 0] || @positive_template
        display_amount = template == @negative_template ? -amount : amount
        result = template
        data = @template_data[template]
        subunit = currency.subunit
        data[:amount].each do |ph, spec|
          result = result.gsub(ph, numeric(display_amount, subunit, spec))
        end
        data[:integral].each do |ph, spec|
          result = result.gsub(ph, numeric(display_amount.to_i, 0, spec))
        end
        result = result.gsub(TEMPLATE_DOT_PH, @decimal) if @replace_template_dot
        Kernel.format(result,
                      currency: currency.code,
                      dsymbol: @needs_dsymbol && currency.dsymbol,
                      symbol: currency.symbol,
                      fractional: @needs_fractional ? money.fractional.abs : 0)
      end

      private

      def numeric(value, subunit, parts)
        spec = parts[:spec] || "#{parts[:spec_prefix]}#{subunit}#{parts[:spec_suffix]}"
        str = Kernel.format(spec, value)
        return str if @decimal == '.' && !@needs_thousand

        apply_separators(str, value, parts[:native_precision])
      end

      def apply_separators(str, value, native_precision)
        dot = str.index('.')
        if dot
          apply_decimal_separator(str, dot, native_precision)
        elsif @needs_thousand && !native_precision
          apply_thousand_if_int_match(str, value)
        else
          str
        end
      end

      def apply_decimal_separator(str, dot, native_precision)
        int_part = str[0...dot]
        int_part.gsub!(THOUSAND_RE, @thousand_replacement) if @needs_thousand && !native_precision
        "#{int_part}#{@decimal}#{str[(dot + 1)..]}"
      end

      def apply_thousand_if_int_match(str, value)
        int_str = value.abs.to_i.to_s
        formatted_int = str.sub(/\A[-+ ]/, '')
        formatted_int == int_str ? str.gsub(THOUSAND_RE, @thousand_replacement) : str
      end

      def compile
        templates = [@format[:negative], @format[:zero], @format[:positive] || Money::DEFAULT_FORMAT]
        @template_data = {}
        has_numeric = false
        compiled = templates.map do |t|
          next nil unless t

          result, amount_pairs, integral_pairs = compile_template(t)
          @template_data[result] = { amount: amount_pairs, integral: integral_pairs }
          has_numeric = true if amount_pairs.any? || integral_pairs.any?
          result.freeze
        end
        @negative_template, @zero_template, @positive_template = compiled
        @templates = { -1 => @negative_template, 0 => @zero_template, 1 => @positive_template }.freeze
        compute_needs(templates.compact.join, has_numeric)
      end

      def compute_needs(joined, has_numeric)
        @needs_fractional = joined.include?('%<fractional>')
        @needs_dsymbol = joined.include?('%<dsymbol>')
        @needs_thousand = @thousand && !@thousand.empty? && has_numeric
        @thousand_replacement = "\\1#{@thousand}" if @needs_thousand
        @replace_template_dot = @decimal != '.' && joined.include?('.')
      end

      def compile_template(template)
        amount_pairs = []
        integral_pairs = []
        amount_idx = 0
        integral_idx = 0
        result = template.gsub(AMOUNT_SPEC_RE) do |match|
          ph = "#{AMOUNT_PH_BASE}#{amount_idx}"
          amount_idx += 1
          amount_pairs << [ph, compile_amount_spec(Regexp.last_match.captures, match)]
          ph
        end
        result = result.gsub(INTEGRAL_SPEC_RE) do
          ph = "#{INTEGRAL_PH_BASE}#{integral_idx}"
          integral_idx += 1
          integral_pairs << [ph, compile_integral_spec(Regexp.last_match.captures)]
          ph
        end
        if @decimal != '.'
          result = if amount_pairs.empty? && integral_pairs.empty?
                     result.gsub('.', TEMPLATE_DOT_PH)
                   else
                     result.gsub(TEMPLATE_DOT_RE, "\\1#{TEMPLATE_DOT_PH}")
                   end
        end
        [result, amount_pairs, integral_pairs]
      end

      TEMPLATE_DOT_RE = /([\uE001\uE002]\d+)\./

      def compile_amount_spec(captures, match_str)
        before_flags, before_prec, after_flags, after_prec, type = captures
        flags = before_flags || after_flags || ''
        precision = before_prec || after_prec
        native_precision = !match_str.start_with?('%<')
        parts = parse_flags_and_precision(flags, precision, type)
        parts[:native_precision] = native_precision
        prefix = "%#{parts[:flags]}#{parts[:width]}"
        if precision
          parts[:spec] = "#{prefix}.#{precision}#{type}".freeze
        elsif native_precision || type == 'd'
          parts[:spec] = "#{prefix}#{type}".freeze
        else
          parts[:spec_prefix] = "#{prefix}.".freeze
          parts[:spec_suffix] = type
        end
        parts
      end

      def compile_integral_spec(captures)
        before_flags, after_flags, type = captures
        flags = before_flags || after_flags || ''
        parts = parse_flags_and_precision(flags, nil, type)
        parts[:spec] = "%#{parts[:flags]}#{parts[:width]}#{type}".freeze
        parts
      end

      def parse_flags_and_precision(flags, precision, type)
        spec_str = precision ? "#{flags}.#{precision}" : flags
        m = SPEC_PARTS_RE.match(spec_str)
        { flags: m[1], width: m[2], precision: m[3], type: type }
      end
    end
  end
end

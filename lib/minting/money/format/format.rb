# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Formats money as a string with a customizable template, thousand delimiter,
    # and decimal separator.
    #
    # @param template [String, Hash, nil] Either a format string with placeholders
    #   (%<symbol>s, %<amount>f, %<currency>s, %<integral>d, %<fractional>d, %<dsymbol>s),
    #   or a Hash with per-sign keys (:positive, :negative, :zero) each
    #   holding a format string. A Hash is convenient for sign-aware formats
    #   such as accounting parentheses:
    #
    #     money.format({ negative: '(%<symbol>s%<amount>f)' })
    #
    #   Missing keys fall back to the module default, so a Hash with only
    #   :negative will still format positives sensibly. The valid keys are
    #   :positive, :negative, :zero; anything else raises ArgumentError.
    #   When +nil+, falls back to +Mint.locale_backend+ if set, otherwise
    #   +"%<symbol>s%<amount>f"+.
    # @param thousand [String, false, nil] Thousands delimiter (e.g., ',' for 1,000).
    #   When +nil+, falls back to +Mint.locale_backend+ if set, otherwise +","+.
    # @param decimal [String, nil] Decimal separator (e.g., '.' or ',').
    #   When +nil+, falls back to +Mint.locale_backend+ if set, otherwise +"."+.
    # @param locale [Symbol, String, nil] Locale key passed to the +Mint.locale_backend+
    #   callable when resolving locale-aware separators and format. Ignored when
    #   +Mint.locale_backend+ is a Hash or nil. Accepts symbols (+:en+, +:'pt-BR'+)
    #   and strings (+"pt-BR"+), passed through as-is (matching Rails +I18n.locale+
    #   convention).
    # @return [String] Formatted money string
    #
    # @raise [ArgumentError] if +template+ is not a String or Hash, the Hash is
    #   empty, or the Hash contains an unrecognised key.
    #
    # @example Basic formatting
    #   money = Money.from(1234.56, 'USD')
    #   money.format                               #=> "$1,234.56"
    #   money.format(thousand: '.', decimal: ',')  #=> "$1.234,56"
    #   money.format(decimal: ',', thousand: '')   #=> "$1234,56"
    #
    # @example Custom templates
    #   money.format('%<amount>f')                              #=> "1234.56"
    #   money.format('%<currency>s %<amount>f')                 #=> "USD 1234.56"
    #   money.format('%<amount>f %<symbol>s')                   #=> "1234.56 $"
    #   money.format('%<symbol>s%<amount>+f')                   #=> "$+1234.56"
    #
    # @example Integral & fractional parts
    #   money.format('%<integral>d.%<fractional>02d')            #=> "1234.56"
    #   price = Money.from(0.99, 'USD')
    #   price.format('%<integral>d dollars and %<fractional>02d cents')
    #   #=> "0 dollars and 99 cents"
    #
    # @example Per-sign Hash format (accounting parentheses)
    #   loss = Money.from(-1234.56, 'USD')
    #   loss.format({ negative: '(%<symbol>s%<amount>f)' })      #=> "($1,234.56)"
    #   Money.from(0, 'BRL').format({ zero: '--' })             #=> "--"
    #
    # @example Padding and alignment
    #   money.format('%<amount>10.2f')                          #=> "   1234.56"
    #   money.format('%<symbol>s%<amount>010.2f')               #=> "$0001234.56"
    #
    # @example Locale-aware formatting (with Mint.locale_backend set)
    #   money.format                       # decimal and thousand come from locale_backend
    #   money.format(locale: :en)          # locale passed to backend callable
    #   money.format(locale: 'pt-BR')      # strings work too
    #
    def format(template = nil, decimal: nil, thousand: nil, width: nil, locale: nil, formatter_class: Formatter2)
      template, decimal, thousand = resolve_format_options(template, decimal:, thousand:, locale:)

      case template
      when Hash # :noop - validated in Formatter.for
      when String then template = { positive: template }
      else        raise ArgumentError, 'Invalid template. Only String or Hash are accepted'
      end

      formatted = formatter_class.for(template, decimal, thousand).format(self)

      width ? formatted.rjust(width) : formatted
    end

    # Alias for {#format}. Takes the same arguments.
    alias to_fs :format

    private

    def resolve_format_options(template, decimal:, thousand:, locale:)
      backend_opts = Mint.resolve_locale_for(locale:)

      template ||= backend_opts[:format] || DEFAULT_FORMAT
      decimal ||= backend_opts[:decimal] || '.'
      if thousand.nil?
        thousand = backend_opts[:thousand] || ','
        thousand = false if thousand == decimal
      end

      [template, decimal, thousand]
    end
  end
end

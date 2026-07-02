# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    PRESETS = {
      amount: { format: '%<amount>f' },
      accounting: { format: { negative: '(%<symbol>s%<amount>f)' } },
      european: { format: '%<amount>f %<symbol>s', decimal: ',', thousand: '.' },
      currency: { format: '%<currency>s %<amount>f' }
    }.freeze

    # Formats money as a string with customizable format, thousand delimiter, and decimal
    #
    # @param preset [Symbol, nil] Named format preset, one of:
    #   +:accounting+, +:european+, +:amount+, +:currency+.
    #   When provided, expands to the preset's format options and merges
    #   with any explicit keyword arguments (kwargs override the preset).
    # @param format [String, Hash, nil] Either a Format string with placeholders
    #   (%<symbol>s, %<amount>f, %<currency>s, %<integral>d, %<fractional>d, %<dsymbol>s),
    #   or a Hash with per-sign keys (:positive, :negative, :zero) each
    #   holding a format string. A Hash is convenient for sign-aware formats
    #   such as accounting parentheses:
    #
    #     money.format(format: { negative: '(%<symbol>s%<amount>f)' })
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
    # @return [String] Formatted money string
    #
    # @raise [ArgumentError] if +preset+ is not a recognised name, or if
    #   +format+ is not a String or Hash, the Hash is empty, or the Hash
    #   contains an unrecognised key.
    #
    # @example Basic formatting
    #   money = Mint.money(1234.56, 'USD')
    #   money.format                               #=> "$1,234.56"
    #   money.format(thousand: '.', decimal: ',')  #=> "$1.234,56"
    #   money.format(decimal: ',', thousand: '')   #=> "$1234,56"
    #
    # @example Preset formats
    #   loss = Mint.money(-1234.56, 'USD')
    #   loss.format(:accounting)                   #=> "($1,234.56)"
    #   money.format(:european)                    #=> "1.234,56 €"
    #   money.format(:amount)                      #=> "1234.56"
    #   money.format(:currency)                    #=> "USD 1234.56"
    #
    # @example Custom formats
    #   money.format(format: '%<amount>f')                    #=> "1234.56"
    #   money.format(format: '%<currency>s %<amount>f')       #=> "USD 1234.56"
    #   money.format(format: '%<amount>f %<symbol>s')         #=> "1234.56 $"
    #   money.format(format: '%<symbol>s%<amount>+f')         #=> "$+1234.56"
    #
    # @example Integral & fractional parts
    #   money.format(format: '%<integral>d.%<fractional>02d')  #=> "1234.56"
    #   price = Mint.money(0.99, 'USD')
    #   price.format(format: '%<integral>d dollars and %<fractional>02d cents')
    #   #=> "0 dollars and 99 cents"
    #
    # @example Per-sign Hash format (accounting parentheses)
    #   loss = Mint.money(-1234.56, 'USD')
    #   loss.format(format: { negative: '(%<symbol>s%<amount>f)' }) #=> "($1,234.56)"
    #   Mint.money(0, 'BRL').format(format: { zero: '--' })        #=> "--"
    #
    # @example Padding and alignment
    #   money.format(format: '%<amount>10.2f')                #=> "   1234.56"
    #   money.format(format: '%<symbol>s%<amount>010.2f')     #=> "$0001234.56"
    #
    # @example Locale-aware formatting (with Mint.locale_backend set)
    #   money.format  # decimal and thousand come from locale_backend
    #
    def format(preset = nil, format: nil, decimal: nil, thousand: nil, width: nil)
      if preset
        config = PRESETS.fetch(preset) { raise ArgumentError, "Unknown format preset: #{preset.inspect}" }
        format ||= config[:format]
        decimal ||= config[:decimal]
        thousand ||= config[:thousand]
        width ||= config[:width]
      end

      validate_separators!(decimal:, thousand:)

      format, decimal, thousand = resolve_locale_for(format, decimal, thousand)

      case format
      when {}, '' then raise ArgumentError, 'format must not be empty'
      when Hash   then validate_format_hash(format)
      when String then format = { positive: format }
      else        raise ArgumentError, 'Invalid format. Only String or Hash are accepted'
      end

      formatted = format_amount(format, decimal:, thousand:)

      width ? formatted.rjust(width) : formatted
    end

    THOUSAND_RE = /(\d)(?=(\d{3})+\z)/

    def to_s
      return format unless Mint.locale_backend.nil?

      subunit  = currency.subunit
      integral = to_i.to_s
      integral.gsub!(THOUSAND_RE, '\1,') if amount.abs >= 1000
      if subunit > 0
        "#{currency.symbol}#{integral}.#{fractional.to_s.rjust(subunit, '0')}"
      else
        "#{currency.symbol}#{integral}"
      end
    end

    alias to_fs :format
  end
end

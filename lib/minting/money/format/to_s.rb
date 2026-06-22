# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    # Formats money as a string with customizable format, thousand delimiter, and decimal
    #
    # @param format [String, Hash, nil] Either a Format string with placeholders
    #   (%<symbol>s, %<amount>f, %<currency>s), or a Hash with per-sign keys
    #   (:positive, :negative, :zero) each holding a format string. A Hash
    #   is convenient for sign-aware formats such as accounting parentheses:
    #
    #     money.to_s(format: { negative: '(%<symbol>s%<amount>f)' })
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
    # @raise [ArgumentError] if +format+ is not a String or Hash, the Hash
    #   is empty, or the Hash contains an unrecognised key.
    #
    # @example Basic formatting
    #   money = Mint.money(1234.56, 'USD')
    #   money.to_s                               #=> "$1,234.56"
    #   money.to_s(thousand: '.', decimal: ',')  #=> "$1.234,56"
    #   money.to_s(decimal: ',', thousand: '')   #=> "$1234,56"
    #
    # @example Custom formats
    #   money.to_s(format: '%<amount>f')                    #=> "1234.56"
    #   money.to_s(format: '%<currency>s %<amount>f')       #=> "USD 1234.56"
    #   money.to_s(format: '%<amount>f %<symbol>s')         #=> "1234.56 $"
    #   money.to_s(format: '%<symbol>s%<amount>+f')         #=> "$+1234.56"
    #
    # @example Per-sign Hash format (accounting parentheses)
    #   loss = Mint.money(-1234.56, 'USD')
    #   loss.to_s(format: { negative: '(%<symbol>s%<amount>f)' }) #=> "($1,234.56)"
    #   Mint.money(0, 'BRL').to_s(format: { zero: '--' })        #=> "--"
    #
    # @example Padding and alignment
    #   money.to_s(format: '%<amount>10.2f')                #=> "   1234.56"
    #   money.to_s(format: '%<symbol>s%<amount>010.2f')     #=> "$0001234.56"
    #
    # @example Locale-aware formatting (with Mint.locale_backend set)
    #   money.to_s  # decimal and thousand come from locale_backend
    #
    def to_s(format: nil, decimal: nil, thousand: nil, width: nil)
      format, decimal, thousand = resolve_locale_for(format, decimal, thousand)

      case format
      when {}, '' then raise ArgumentError, 'format must not be empty'
      when Hash   then validate_format_hash(format)
      when String then format = { positive: format }
      else        raise ArgumentError, 'Invalid format. Only String or Hash are accepted'
      end

      formatted = format_amount(format, decimal: decimal, thousand: thousand)

      width ? formatted.rjust(width) : formatted
    end
  end
end

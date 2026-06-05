# frozen_string_literal: true

module Mint
  # Formatting functionality for Money objects
  class Money
    # Formats money as a string with customizable format, thousand delimiter, and decimal
    #
    # @param format [String, Hash] Either a Format string with placeholders
    #   (%<symbol>s, %<amount>f, %<currency>s), or a Hash with per-sign keys
    #   (:positive, :negative, :zero) each holding a format string. A Hash
    #   is convenient for sign-aware formats such as accounting parentheses:
    #
    #     money.to_s(format: { negative: '(%<symbol>s%<amount>f)' })
    #
    #   Missing keys fall back to the module default, so a Hash with only
    #   :negative will still format positives sensibly. The valid keys are
    #   :positive, :negative, :zero; anything else raises ArgumentError.
    # @param thousand [String, false] Thousands delimiter (e.g., ',' for 1,000)
    # @param decimal [String] Decimal separator (e.g., '.' or ',')
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
    def to_s(format: '%<symbol>s%<amount>f', decimal: '.', thousand: ',', width: nil)
      case format
      when {}, '', nil then raise ArgumentError, 'format must not be empty or null'
      when Hash        then validate_format_hash!(format)
      when String # noop
      else raise ArgumentError, 'Invalid format'
      end

      formatted = format_amount(format)

      formatted.tr!('.', decimal) if decimal != '.'

      unless thousand.empty?
        # Regular expression courtesy of Money gem
        # Matches digits followed by groups of 3 digits until non-digit or end
        formatted.gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/, "\\1#{thousand}")
      end

      formatted = formatted.rjust(width) if width
      formatted
    end

    private

    def validate_format_hash!(format)
      unknown = format.keys - %i[positive negative zero]

      raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
    end

    def format_amount(format)
      format = { positive: format } if format.is_a?(String)
      positive_format = format[:positive]
      negative_format = format[:negative]
      zero_format = format[:zero]

      if amount.negative? && negative_format
        format = negative_format
        value = -amount
      elsif amount.zero? && zero_format
        format = zero_format
        value = amount
      else
        format = positive_format
        value = amount
      end
      format ||= '%<symbol>s%<amount>f'

      # Automatically adjust decimal places based on currency subunit
      adjusted_format = format.gsub(/%<amount>(\+?\d*)f/,
                                    "%<amount>\\1.#{currency.subunit}f")

      Kernel.format(adjusted_format,
                    amount: value,
                    currency: currency_code,
                    symbol: currency.symbol)
    end
  end
end

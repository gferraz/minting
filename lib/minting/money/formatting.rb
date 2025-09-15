module Mint
  # Formatting functionality for Money objects
  class Money
    # Formats money as a string with customizable format, thousand delimiter, and decimal
    #
    # @param format [String] Format string with placeholders: %<symbol>s, %<amount>f, %<currency>s
    # @param thousand [String, false] Thousands delimiter (e.g., ',' for 1,000)
    # @param decimal [String] Decimal separator (e.g., '.' or ',')
    # @return [String] Formatted money string
    #
    # @example Basic formatting
    #   money = Mint.money(1234.56, 'USD')
    #   money.to_s                               #=> "$1,234.56"
    #   money.to_s(thousand: '.', decimal: ',')  #=> "$.1234,56"
    #   money.to_s(decimal: ',', thousand: '')   #=> "$1234,56"
    #
    # @example Custom formats
    #   money.to_s(format: '%<amount>f')                    #=> "1234.56"
    #   money.to_s(format: '%<currency>s %<amount>f')       #=> "USD 1234.56"
    #   money.to_s(format: '%<amount>f %<symbol>s')         #=> "1234.56 $"
    #   money.to_s(format: '%<symbol>s%<amount>+f')         #=> "$+1234.56"
    #
    # @example Padding and alignment
    #   money.to_s(format: '%<amount>10.2f')                #=> "   1234.56"
    #   money.to_s(format: '%<symbol>s%<amount>010.2f')     #=> "$0001234.56"
    #
    def to_s(format: '%<symbol>s%<amount>f', decimal: '.', thousand: ',', width: nil)
      raise ArgumentError, 'Invalid format' unless format.is_a?(String) || format.is_a?(Hash)

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

    def format_amount(format)
      # binding.irb if format.is_a? Hash
      format = { positive: format } if format.is_a?(String)
      value = amount

      if amount.negative? && format[:negative]
        format = format[:negative]
        value = -amount
      elsif amount.zero? && format[:zero]
        format = format[:zero]
      else
        format = format[:positive]
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

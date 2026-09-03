# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    # Match a digit followed by groups of 3 digits until end of string — inserts thousand separators.
    THOUSAND_RE = /(\d)(?=(\d{3})+\z)/

    # Returns a string representation of the money amount.
    #
    # When no {Mint.locale_backend} is configured, uses +currency.symbol+,
    # comma thousands separators for amounts >= 1000, and decimal for the
    # fractional part. When a locale backend is set, delegates to {#format}
    # so locale-aware formatting takes effect.
    #
    # Unlike {#format}, this method takes **no arguments** — use
    # {#format} (alias {#to_fs}) for custom formatting.
    #
    # @return [String] formatted money string
    #
    # @example
    #   Money.from(1234.56, 'USD').to_s  #=> "$1,234.56"
    #   Money.from(0.99, 'USD').to_s     #=> "$0.99"
    #   Money.from(100, 'JPY').to_s      #=> "¥100"
    def to_s
      return format unless Mint.locale_backend.nil?

      subunit = currency.subunitz      sign = amount.negative? ? '-' : ''
      major = integral.abs.to_s
      major.gsub!(THOUSAND_RE, '\1,') if amount.abs >= 1000
      if subunit > 0
        minor = fractional.abs.to_s.rjust(subunit, '0')
        "#{currency.symbol}#{sign}#{major}.#{minor}"
      else
        "#{currency.symbol}#{sign}#{major}"
      end
    end
  end
end

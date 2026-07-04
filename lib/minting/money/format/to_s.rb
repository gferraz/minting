# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    # Named format presets for use with {#format}.
    #
    # Each preset defines a +:format+ template and optional +:decimal+,
    # +:thousand+, and +:width+ overrides.
    #
    # @example
    #   Mint::Money::PRESETS[:accounting]
    #   #=> { format: { negative: '(%<symbol>s%<amount>f)' } }
    #
    # @return [Hash{Symbol => Hash{Symbol => Object}}] a frozen hash of presets
    PRESETS = {
      amount: { format: '%<amount>f' },
      accounting: { format: { negative: '(%<symbol>s%<amount>f)' } },
      european: { format: '%<amount>f %<symbol>s', decimal: ',', thousand: '.' },
      currency: { format: '%<currency>s %<amount>f' }
    }.freeze

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
    #   Mint.money(1234.56, 'USD').to_s  #=> "$1,234.56"
    #   Mint.money(0.99, 'USD').to_s     #=> "$0.99"
    #   Mint.money(100, 'JPY').to_s      #=> "¥100"
    def to_s
      return format unless Mint.locale_backend.nil?

      subunit = currency.subunit
      major = integral.to_s
      major.gsub!(THOUSAND_RE, '\1,') if amount.abs >= 1000
      if subunit > 0
        minor = fractional.abs.to_s.rjust(subunit, '0')
        "#{currency.symbol}#{major}.#{minor}"
      else
        "#{currency.symbol}#{major}"
      end
    end
  end
end

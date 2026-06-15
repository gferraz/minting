# frozen_string_literal: true

# :nodoc:
module Mint
  class << self
    # Optional callable that returns a Hash with locale-aware formatting defaults.
    #
    # The callable receives no arguments and returns a Hash with these keys:
    #   [+:decimal+]   Decimal separator (e.g. +","+)
    #   [+:thousand+]  Thousands delimiter (e.g. +"."+)
    #   [+:format+]    Format template string (e.g. +"%<amount>f %<symbol>s"+)
    #
    # When set, +#to_s+ and +#format+ use these values as fallbacks when the
    # corresponding parameter is not explicitly provided.
    #
    # @example Rails I18n integration (in minting-rails railtie)
    #   Mint.locale_backend = -> {
    #     fmt = I18n.t('number.currency.format')
    #     {
    #       decimal: fmt[:separator],
    #       thousand: fmt[:delimiter],
    #       format: fmt[:format] == '%n %u' ? '%<amount>f %<symbol>s' : '%<symbol>s%<amount>f'
    #     }
    #   }
    #
    # @return [Proc, #call, nil]
    attr_accessor :locale_backend
  end
end

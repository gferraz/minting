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

  class Money
    private

    # Resolves format/decimal/thousand from locale_backend when not explicitly given.
    # @private
    def resolve_locale_for(format, decimal, thousand)
      locale = locale_backend

      [format || locale[:format] || '%<symbol>s%<amount>f',
       decimal || locale[:decimal] || '.',
       thousand.nil? ? (locale[:thousand] || ',') : thousand]
    end

    def locale_backend
      case bk = Mint.locale_backend
      when Hash     then bk
      when NilClass then {}
      else
        return bk.call if bk.respond_to?(:call)

        warn "ignoring invalid locale_backend: #{bk.inspect}"
        {}
      end
    end
  end
end

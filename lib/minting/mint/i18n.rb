# frozen_string_literal: true

# :nodoc:
module Mint
  class << self
    # Optional callable that returns a Hash with locale-aware formatting defaults.
    #
    # The callable receives the locale (as passed to +#format+'s +locale:+ kwarg,
    # or +nil+ when omitted) and returns a Hash with these keys (strings and
    # symbols are treated interchangeably):
    #   [+decimal+]   Decimal separator (e.g. +","+) — also accepts +:separator+
    #   [+thousand+]  Thousands delimiter (e.g. +"."+) — also accepts +:delimiter+
    #   [+format+]    Format template string (e.g. +"%<amount>f %<symbol>s"+)
    #
    # When set, +#to_formatted_s+ and +#format+ use these values as fallbacks when the
    # corresponding parameter is not explicitly provided.
    #
    # @example Per-locale formatting with string keys
    #   LOCALE_DATA = {
    #     'en'    => { decimal: '.', thousand: ',', format: '%<symbol>s%<amount>f' },
    #     'de'    => { decimal: ',', thousand: '.', format: '%<amount>f %<currency>s' },
    #   }.freeze
    #   Mint.locale_backend = ->(locale) { LOCALE_DATA[locale.to_s] || {} }
    #
    # @example Rails I18n integration (direct pass-through, no mapping needed)
    #   Mint.locale_backend = ->(locale = nil) {
    #     I18n.with_locale(locale || I18n.default_locale) do
    #       I18n.t('number.currency.format', default: {})
    #     end
    #   }
    #
    # @return [Proc, #call, nil]
    attr_accessor :locale_backend
  end

  # Resolves format/decimal/thousand from locale_backend when not explicitly given.
  # @api private
  def self.resolve_locale_for(format, decimal, thousand, locale: nil)
    lc = resolve_locale_backend(locale)

    [format || fetch_locale_key(lc, :format) || Mint::Money::DEFAULT_FORMAT,
     decimal || fetch_locale_key(lc, :decimal) || '.',
     thousand.nil? ? (fetch_locale_key(lc, :thousand) || ',') : thousand]
  end

  # Looks up a locale key from a hash, trying both symbol and string forms.
  #
  # Supports aliases: +:decimal+ checks +:decimal+ and +:separator+,
  # +:thousand+ checks +:thousand+ and +:delimiter+, +:format+ checks +:format+.
  #
  # @param hash [Hash] locale config hash
  # @param key [Symbol] the primary key (+:decimal+, +:thousand+, or +:format+)
  # @return [String, nil] the value found, or nil
  # @api private
  def self.fetch_locale_key(hash, key)
    aliases = { decimal: %i[decimal separator], thousand: %i[thousand delimiter], format: [:format] }
    aliases.fetch(key).each do |name|
      val = hash[name] || hash[name.to_s]
      return val unless val.nil?
    end
    nil
  end

  # Resolves the locale backend configuration into a Hash.
  #
  # Handles three backend types:
  # - +Hash+: returned as-is
  # - +Proc+/callable: called with the locale (or no args for 0-arity),
  #   result must be a Hash or nil
  # - +nil+: returns empty Hash
  #
  # Invalid return values or backends emit a warning and return +{}+.
  #
  # @param locale [Symbol, String, nil] locale passed to the backend callable
  # @return [Hash] locale configuration (possibly empty)
  # @api private
  def self.resolve_locale_backend(locale = nil)
    case bk = Mint.locale_backend
    when Hash     then bk
    when NilClass then {}
    else
      if bk.respond_to?(:call)
        args = bk.respond_to?(:arity) && bk.arity == 0 ? [] : [locale]
        result = bk.call(*args)
        return result if result.is_a?(Hash) || result.nil?

        warn "ignoring invalid locale_backend result: #{result.inspect}"
        return {}
      end

      warn "ignoring invalid locale_backend: #{bk.inspect}"
      {}
    end
  end
end

# frozen_string_literal: true

require_relative 'allocation/allocation'
require_relative 'allocation/split'
require_relative 'arithmetics/methods'
require_relative 'arithmetics/operators'
require_relative 'clamp'
require_relative 'coercion'
require_relative 'comparable'
require_relative 'constructors'
require_relative 'conversion'
require_relative 'format/formatting'
require_relative 'format/to_s'

module Mint
  # Money constructors
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    attr_reader :amount, :currency

    # Returns the ISO 3-letter currency code string.
    #
    # @return [String] the ISO currency code (e.g., "USD", "EUR", "BRL")
    # @example
    #   Mint.money(100, 'USD').currency_code  #=> "USD"
    def currency_code = currency.code

    # Returns the monetary amount expressed in the currency's smallest unit (fractional units).
    # For example, cents for USD (subunit 2), yen for JPY (subunit 0), fils for IQD (subunit 3).
    #
    # @return [Integer] the amount in fractional units
    # @example
    #   Mint.money(1234.56, 'USD').fractional  #=> 123456
    #   Mint.money(1000, 'JPY').fractional     #=> 1000
    #   Mint.money(123.456, 'IQD').fractional  #=> 123456
    def fractional = (amount * currency.fractional_multiplier).to_i

    # Generates a stable hash key for Money instances.
    #
    # @return [Integer] the calculated hash value
    def hash = [amount, currency_code].hash

    # Returns a standard developer-oriented string inspection of the Money object.
    #
    # @return [String] the formatted inspect representation
    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", amount
    end

    # Helper method to verify if another object has the identical currency.
    #
    # @param other [Currency] the target currency to compare
    # @return [Boolean] true if currencies match, false otherwise
    def same_currency?(other) = other.currency == currency
  end
end

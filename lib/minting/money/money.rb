# frozen_string_literal: true

require_relative 'allocation/allocation'
require_relative 'allocation/split'
require_relative 'arithmetics/methods'
require_relative 'arithmetics/operators'
require_relative 'clamp'
require_relative 'coercion'
require_relative 'comparable'
require_relative 'constructors'
require_relative 'parse'
require_relative 'conversion'
require_relative 'format/formatter'
require_relative 'format/to_s'
require_relative 'format/format'
require_relative 'rounding'

module Mint
  # Represents a monetary value paired with a currency.
  # Money objects are immutable and support arithmetic, comparison,
  # formatting, allocation, and parsing operations.
  class Money
    attr_reader :amount, :currency

    # Money::Currency is the canonical way to access Currency class
    Currency = Mint::Currency

    # Returns the ISO 3-letter currency code string.
    #
    # @return [String] the ISO currency code (e.g., "USD", "EUR", "BRL")
    # @example
    #   Money.from(100, 'USD').currency_code  #=> "USD"
    def currency_code = currency.code

    # Returns the monetary amount expressed in the currency's smallest unit (fractional units).
    # For example, cents for USD (subunit 2), yen for JPY (subunit 0), fils for IQD (subunit 3).
    #
    # @return [Integer] the amount in fractional units
    # @example
    #   Money.from(1234.56, 'USD').subunits  #=> 123456
    #   Money.from(1000, 'JPY').subunits     #=> 1000
    #   Money.from(123.456, 'IQD').subunits  #=> 123456
    def subunits = (amount * currency.fractional_multiplier).to_i

    # Returns the whole-unit (integral) part of the amount.
    # @example
    #   Money.from(1234.56, 'USD').integral  #=> 1234
    #   Money.from(1000, 'JPY').integral     #=> 1000
    #   Money.from(-9.99, 'USD').integral    #=> -9
    def integral = amount.to_i

    alias to_i integral

    # Returns the fractional part of the amount.
    # @example
    #   Money.from(1234.56, 'USD').fractional  #=> 56
    #   Money.from(1000, 'JPY').fractional     #=> 0
    #   Money.from(123.456, 'IQD').fractional  #=> 456
    def fractional = ((amount - amount.to_i) * currency.fractional_multiplier).to_i

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
  end
end

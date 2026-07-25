# frozen_string_literal: true

# :nodoc:
module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code.
  # Currency objects are immutable and define the properties of a monetary unit
  # including its subunit precision, display symbol, and formatting rules.
  #
  # Currency identity is defined by its ISO code — two Currency objects with
  # the same +code+ are considered equal regardless of other attributes.
  # The Registry guarantees that only one canonical Currency exists per code.
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  class Currency
    # @return [String] ISO 4217 currency code (e.g., "USD", "EUR")
    attr_reader :code

    # @return [String, nil] Associated country code
    attr_reader :country

    # @return [String, nil] A longer, code-prefixed variant to distinguish
    #   currencies that share the same primary symbol (e.g. "US$" for USD, "C$" for CAD).
    attr_reader :disambiguate_symbol

    # @return [Integer] 10^subunit, used for fractional conversions
    attr_reader :fractional_multiplier

    # @return [Rational] Smallest representable amount (1/fractional_multiplier)
    attr_reader :minimum_amount

    # @return [String, nil] Currency name
    attr_reader :name

    # @return [Integer] Parser precedence for symbol detection
    attr_reader :priority

    # @return [Integer] Number of decimal places (0 for JPY, 2 for USD, 3 for IQD)
    attr_reader :subunit

    # @return [String, nil] Display symbol (e.g., "$", "€", "R$")
    attr_reader :symbol

    # @param code [String] ISO 4217 currency code
    # @param symbol [String] Display symbol
    # @param subunit [Integer] Number of decimal places (default 0)
    # @param priority [Integer] Parser precedence for symbol detection (default 0)
    # @param country [String, nil] Associated country code (default nil)
    # @param name [String, nil] Currency name (default nil)
    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil,
                   disambiguate_symbol: nil)
      @code = code
      @country = country
      @name = name
      @priority = priority.to_i
      @subunit = subunit.to_i
      @symbol = symbol.nil? || symbol.empty? ? nil : symbol

      @fractional_multiplier = 10**@subunit
      @minimum_amount = Rational(1, @fractional_multiplier)
      @disambiguate_symbol = [code, @symbol].include?(disambiguate_symbol) ? nil : disambiguate_symbol
      freeze
    end

    # Two Currency objects are equal if they share the same ISO code.
    def ==(other) = other.is_a?(self.class) && code == other.code

    # @return [String, nil] disambiguate_symbol or code/symbol fallback
    def dsymbol = disambiguate_symbol || (Registry.symbol_shared?(symbol) ? code : symbol)

    # Currency identity is by code — two objects with the same code are +eql?+
    # regardless of other attributes. This makes Currency usable as a Hash key
    # where lookup is by currency identity (ISO code).
    def eql?(other) = other.is_a?(Currency) && code == other.code

    # @return [Integer] stable hash based on currency code
    def hash = code.hash

    # @return [String] debug representation
    def inspect = "<Currency:(#{code} #{symbol} #{subunit} #{name})>"

    # Normalizes a numeric amount for this currency.
    #
    # @param amount [Numeric] the monetary amount to normalize
    # @return [Rational] the amount converted to +Rational+ and rounded to
    #   the currency's subunit precision (up by default)
    # @example
    #   usd = Money::Currency.for_code('USD')
    #   usd.normalize_amount(10.567)  #=> (10567/1000)
    #   usd.normalize_amount("5.25")  #=> (21/4)
    #
    # @see Money.with_rounding Custom rounding modes via {Money.with_rounding}
    def normalize_amount(amount)
      if Currency.custom_rounding_active?
        amount.to_r.round(subunit, half: Thread.current[Currency::ROUNDING_THREAD_KEY])
      else
        amount.to_r.round(subunit)
      end
    end

    # Returns the cached frozen zero-Money for this currency.
    #
    # @return [Money] a frozen zero-Money instance
    # @example
    #   Money::Currency.for_code('USD').zero  #=> [USD 0.00]
    def zero = Registry.zero_for(self)
  end
end

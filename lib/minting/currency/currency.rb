# frozen_string_literal: true

# :nodoc:
module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code.
  # Currency objects are immutable and define the properties of a monetary unit
  # including its subunit precision, display symbol, and formatting rules.
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  # @attr_reader code [String] ISO 4217 currency code (e.g., "USD", "EUR")
  # @attr_reader subunit [Integer] Number of decimal places (0 for JPY, 2 for USD, 3 for IQD)
  # @attr_reader symbol [String] Display symbol (e.g., "$", "€", "R$")
  # @attr_reader priority [Integer] Parser precedence for symbol detection
  # @attr_reader country [String, nil] Associated country code
  # @attr_reader name [String, nil] Currency name
  # @attr_reader fractional_multiplier [Integer] 10^subunit, used for fractional conversions
  # @attr_reader minimum_amount [Rational] Smallest representable amount (1/fractional_multiplier)
  Currency = Data.define(:code, :subunit, :symbol, :priority, :country, :name,
                         :fractional_multiplier) do
    # @param code [String] ISO 4217 currency code
    # @param symbol [String] Display symbol
    # @param subunit [Integer] Number of decimal places (default 0)
    # @param priority [Integer] Parser precedence for symbol detection (default 0)
    # @param country [String, nil] Associated country code (default nil)
    # @param name [String, nil] Currency name (default nil)
    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil)
      subunit = subunit.to_i
      priority = priority.to_i
      fractional_multiplier = 10**subunit
      super(code:, subunit:, symbol:, priority:, country:, name:,
            fractional_multiplier:)
    end

    # @return [String] debug representation
    def inspect = "<Currency:(#{code} #{symbol} #{subunit} #{name})>"

    # @return [Rational] smallest representable amount (1/fractional_multiplier)
    def minimum_amount = Rational(1, fractional_multiplier)

    # Normalizes numeric amounts for this currency
    # 1. Converts to Rational
    # 2. Rounds to respect currency subunit
    def normalize_amount(amount) = Mint::Rounding.apply(amount, subunit)

    def zero = Registry.zero_for(self)
  end

  # Registers a new currency, raising a KeyError if already registered.
  #
  # @param code [String] the unique currency code
  # @param subunit [Integer] the decimal subunit precision, defaults to 0
  # @param symbol [String] the display symbol
  # @param priority [Integer] parser precedence priority
  # @return [Currency] the newly registered Currency instance
  # @raise [ArgumentError] if the code contains invalid characters
  # @raise [KeyError] if the currency code is already registered
  def Currency.register(code:, subunit: 0, symbol: '', priority: 0)
    Registry.register(code:, subunit:, symbol:, priority:)
  end

  # Resolves an object into a {Currency}, returning +nil+ when it can't.
  #
  # Accepts +nil+, +String+, {Currency}, or {Money}.
  # Passing a {Money} extracts its currency
  #
  # @param object [String, Currency, Money, nil] a currency code, object, or +nil+
  # @return [Currency, nil] the resolved Currency, or +nil+ if +object+ is +nil+
  #   or the code is not registered
  # @raise [ArgumentError] if +object+ is an unsupported type (e.g. +Integer+)
  def Currency.resolve(object)
    case object
    when NilClass then nil
    when Currency then object
    when Money    then object.currency
    when String   then Currency.for_code object
    else          raise ArgumentError, "currency must be [Currency], [Money], [String] or nil (#{object})"
    end
  end

  # Resolves an object into a {Currency}, raising on failure.
  #
  # Like {.resolve} but raises when the result would be +nil+.
  #
  # @param object [String, Currency, Money, nil] a currency code, object, or +nil+
  # @return [Currency] the resolved Currency
  # @raise [ArgumentError] if +object+ cannot be resolved into a registered currency
  def Currency.resolve!(object)
    resolve(object) or raise ArgumentError, "Could not resolve (#{object}) into a currency"
  end

  # Looks up a registered currency by its alpha code.
  #
  # @param code [String] the currency code
  # @return [Currency, nil] the registered Currency, or +nil+ if not found
  def Currency.for_code(code)
    Registry.currencies[code]
  end

  # Looks up a currency by its display symbol.
  #
  # @param symbol [String] the display symbol (e.g. "$", "R$")
  # @return [Currency, nil] the highest-priority currency for the symbol
  def Currency.for_symbol(symbol)
    Registry.currency_for_symbol(symbol)
  end

  # Returns a zero {Money} in the given currency, useful as a default value
  # for discounts, totals, or placeholders.
  #
  # @param currency [String, Currency] a currency code or object
  # @return [Money] a frozen zero-Money
  # @raise [ArgumentError] if the currency can't be resolved
  def Currency.zero(currency) = Registry.zero_for(Currency.resolve!(currency))
end

# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Creates a new Money immutable object with the specified amount and currency
    # @param amount [Numeric] The monetary amount
    # @param currency [Currency, String] The currency code or currency object
    # @return [Money] the new Money instance
    # @raise [ArgumentError] If amount is not numeric
    # @raise [Mint::UnknownCurrency] If currency cannot be resolved
    # @example
    #   Money.from(10, 'USD')  #=> [USD 10.00]
    def self.from(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)

      currency = Currency.resolve!(currency)
      amount = currency.normalize_amount(amount)

      amount.zero? ? currency.zero : new(amount, currency)
    end

    # Creates a new Money without a currency (ISO 4217 XXX — "No Currency").
    #
    # @param amount [Numeric] The monetary amount
    # @return [Money] a Money instance with the XXX currency
    # @raise [ArgumentError] If amount is not numeric
    # @example
    #   Money.no_currency(100)  #=> [XXX 100]
    def self.no_currency(amount) = from(amount, 'XXX')

    # Parses a human-readable money string into a {Money} object.
    #
    # Returns +nil+ when the input is invalid or currency cannot be determined.
    #
    # @param input [String] Amount input, optionally including a currency symbol or code
    # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
    # @return [Money, nil]
    #
    # @example With explicit currency
    #   Money.parse('19.99', 'USD')    #=> [USD 19.99]
    #   Money.parse('garbage', 'USD')  #=> nil
    #
    # @example With symbol or code in the string
    #   Money.parse('$19.99')            #=> [USD 19.99]
    #   Money.parse('USD 1,234.56')    #=> [USD 1234.56]
    def self.parse(input, currency = nil) = Mint.parse(input, currency)

    # Like {.parse} but raises on failure.
    #
    # @param input [String] Amount input, optionally including a currency symbol or code
    # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
    # @return [Money]
    # @raise [ArgumentError] when +input+ is invalid or currency cannot be determined
    #
    # @example
    #   Money.parse!('19.99', 'USD')    #=> [USD 19.99]
    #   Money.parse!('garbage', 'USD')  #=> ArgumentError
    def self.parse!(input, currency = nil) = Mint.parse!(input, currency)

    # Returns a frozen zero Money in the given currency.
    #
    # @param currency [String, Currency] a currency code or object
    # @return [Money] a frozen zero-Money
    # @raise [Mint::UnknownCurrency] if the currency can't be resolved
    def self.zero(currency) = Currency.resolve!(currency).zero

    # Builds a Money from a subunit (smallest-unit) Integer amount.
    # This is the inverse of {#subunits}: for USD, the subunit is
    # 1 cent; for JPY it is 1 yen; for IQD it is 1 dinar (subunit 3).
    #
    # @param subunits [Integer] the amount expressed in the currency's
    #   smallest unit (e.g. cents). Must be an Integer to preserve exactness.
    # @param currency [String, Symbol, Currency] the currency identifier
    # @return [Money] the resulting Money instance
    # @raise [ArgumentError] if +subunits+ is not an Integer
    # @raise [Mint::UnknownCurrency] if +currency+ is not registered
    #
    # @example USD cents
    #   Money.from_subunits(123_456, 'USD') #=> [USD 1234.56]
    # @example JPY (subunit 0)
    #   Money.from_subunits(1234, 'JPY')    #=> [JPY 1234]
    # @example Round trip
    #   m = Mint.money(9.99, 'USD')
    #   Money.from_subunits(m.subunits, 'USD') == m #=> true
    def self.from_subunits(subunits, currency)
      raise ArgumentError, 'subunits must be an Integer' unless subunits.is_a?(Integer)

      currency = Currency.resolve!(currency)
      amount = Rational(subunits, currency.fractional_multiplier)
      amount.zero? ? currency.zero : new(amount, currency)
    end

    # Returns a new Money object with the specified amount, or self if unchanged.
    # This is the primary method for creating a modified copy of a Money instance
    # while preserving immutability.
    #
    # @param amount [Numeric] The new monetary amount
    # @return [Money] A new Money object with the new amount, or self if the amount is unchanged
    # @example
    #   price = Mint.money(10.00, 'USD')
    #   price.copy_with(amount: 15.00)  #=> [USD 15.00]
    #   price.copy_with(amount: 10.00)  #=> [USD 10.00] (returns self)
    def copy_with(amount:)
      amount = currency.normalize_amount(amount)

      if amount == self.amount
        self
      elsif amount.zero?
        currency.zero
      else
        Money.new(amount, currency)
      end
    end

    # Returns a new Money with the given amount in the same currency.
    #
    # @deprecated Use {#copy_with} instead. Will be removed in v2.
    # @param new_amount [Numeric] the new monetary amount
    # @return [Money] a new Money instance, or self if unchanged
    # @example
    #   Mint.money(10, 'USD').mint(15)  #=> [USD 15.00]
    def mint(new_amount)
      warn 'Money#mint is now deprecated and will be removed in v2'
      copy_with(amount: new_amount)
    end

    private

    # Initializes a new Money object with the given amount and currency.
    # @param amount [Numeric] The monetary amount
    # @param currency [Currency] The currency object
    def initialize(amount, currency)
      @amount = amount
      @currency = currency
      freeze
    end
  end
end

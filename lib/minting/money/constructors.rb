# frozen_string_literal: true

module Mint
  # Money constructors
  class Money
    # Creates a new Money immutable object with the specified amount and currency
    # @param amount [Numeric] The monetary amount
    # @param currency [Currency, String] The currency code or currency object
    # @raise [ArgumentError] If amount is not numeric or currency is invalid
    def self.create(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)

      checked_currency = Mint.currency(currency)
      raise ArgumentError, "Currency not found (#{currency})" unless checked_currency

      amount = checked_currency.normalize_amount(amount)

      amount.zero? ? Mint.zero(checked_currency) : new(amount, checked_currency)
    end

    # Builds a Money from a fractional (smallest-unit) Integer amount.
    # This is the inverse of {#fractional}: for USD, the fractional unit is
    # 1 cent; for JPY it is 1 yen; for IQD it is 1 dinar (subunit 3).
    #
    # @param fractional [Integer] the amount expressed in the currency's
    #   smallest unit (e.g. cents). Must be an Integer to preserve exactness.
    # @param currency [String, Symbol, Currency] the currency identifier
    # @return [Money] the resulting Money instance
    # @raise [ArgumentError] if +fractional+ is not an Integer or +currency+
    #   is not registered
    #
    # @example USD cents
    #   Money.from_fractional(123_456, 'USD') #=> [USD 1234.56]
    # @example JPY (subunit 0)
    #   Money.from_fractional(1234, 'JPY')    #=> [JPY 1234]
    # @example Round trip
    #   m = Mint.money(9.99, 'USD')
    #   Money.from_fractional(m.fractional, 'USD') == m #=> true
    def self.from_fractional(fractional, currency)
      raise ArgumentError, 'fractional must be an Integer' unless fractional.is_a?(Integer)

      checked_currency = Mint.currency(currency)
      raise ArgumentError, "Currency not found (#{currency})" unless checked_currency

      amount = Rational(fractional, checked_currency.fractional_multiplier)

      amount.zero? ? Mint.zero(checked_currency) : new(amount, checked_currency)
    end

    # Returns a new Money object with the specified amount, or self if unchanged.
    # This is the primary method for creating a modified copy of a Money instance
    # while preserving immutability.
    #
    # @param new_amount [Numeric] The new monetary amount
    # @return [Money] A new Money object with the new amount, or self if the amount is unchanged
    # @example
    #   price = Mint.money(10.00, 'USD')
    #   price.mint(15.00)  #=> [USD 15.00]
    #   price.mint(10.00)  #=> [USD 10.00] (returns self)
    def mint(new_amount)
      new_amount = currency.normalize_amount(new_amount)

      if new_amount == amount
        self
      elsif new_amount.zero?
        Mint.zero(currency)
      else
        Money.new(new_amount, currency)
      end
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

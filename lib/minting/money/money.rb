module Mint
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'.freeze

    attr_reader :amount, :currency

    # Creates a new Money immutable object with the specified amount and currency
    # @param amount [Numeric] The monetary amount
    # @param currency [Currency] The currency object
    # @raise [ArgumentError] If amount is not numeric or currency is invalid
    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)
      raise ArgumentError, 'currency must be a Currency object' unless currency.is_a?(Currency)

      @amount = amount.to_r.round(currency.subunit)
      @currency = currency
      freeze
    end

    # Returns the ISO 3-letter currency code string.
    #
    # @return [String] the ISO currency code
    def currency_code = currency.code

    # Generates a stable hash key for Money instances.
    #
    # @return [Integer] the calculated hash value
    def hash = [amount, currency_code].hash

    # Returns a new Money object with the specified amount, or self if unchanged
    # @param new_amount [Numeric] The new amount
    # @return [Money] A new Money object or self
    def mint(new_amount)
      new_amount == amount ? self : Money.new(new_amount, currency)
    end

    # Returns a standard developer-oriented string inspection of the Money object.
    #
    # @return [String] the formatted inspect representation
    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", amount
    end

    # Helper method to verify if another object has the identical currency.
    #
    # @param other [Object] the target object to compare
    # @return [Boolean] true if currencies match, false otherwise
    def same_currency?(other) = other.respond_to?(:currency) && other.currency == currency
  end
end

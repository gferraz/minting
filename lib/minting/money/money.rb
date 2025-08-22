# frozen_string_literal: true

module Mint
  class Money
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    attr_reader :amount, :currency

    # Creates a new Money immutable object with the specified amount and currency
    # @param amount [Numeric] The monetary amount
    # @param currency [Currency] The currency object
    # @raise [ArgumentError] If amount is not numeric or currency is invalid
    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)

      unless currency.is_a?(Currency)
        raise ArgumentError,
              'currency must be a Currency object'
      end

      @amount = amount.to_r.round(currency.subunit)
      @currency = currency
    end

    def currency_code
      currency.code
    end

    # Returns a new Money object with the specified amount, or self if unchanged
    # @param new_amount [Numeric] The new amount
    # @return [Money] A new Money object or self

    def mint(new_amount)
      new_amount.to_r == amount ? self : Money.new(new_amount, currency)
    end

    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", amount
    end

    def same_currency?(other)
      other.respond_to?(:currency) && other.currency == currency
    end
  end
end

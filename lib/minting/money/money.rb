# frozen_string_literal: true

module Mint
  # Money is a value object for monetary values
  # Money is immutable
  class Money
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    attr_reader :amount, :currency

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

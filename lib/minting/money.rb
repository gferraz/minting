require 'minting/money/arithmetics'
require 'minting/money/coercion'
require 'minting/money/comparable'

class Mint
  class Money
    attr_reader :currency

    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Rational'            unless amount.is_a?(Rational)
      raise ArgumentError, 'currency must be a Currency object' unless currency.is_a?(Currency)
      @amount = amount.round(currency.subunit)
      @currency = currency
    end

    def currency_code
      @currency.code
    end

    def mint(amount)
      Money.new(amount, currency)
    end

    def inspect
      format "[#{currency_code} %0.#{currency.subunit}f]", @amount
    end

    def to_i
      @amount.to_i
    end

    def to_r
      @amount
    end

    def nonzero?
      @amount.nonzero?
    end

    def zero?
      @amount.zero?
    end
  end
end

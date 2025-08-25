# frozen_string_literal: true

module Mint
  # :nodoc
  # Arithmetic functions for money objects
  class Money
    def abs
      mint(amount.abs)
    end

    def negative?
      amount.negative?
    end

    def positive?
      amount.positive?
    end

    def succ
      mint(amount + currency.minimum_amount)
    end

    def +(addend)
      return self if addend.respond_to?(:zero?) && addend.zero?
      return mint(amount + addend.amount) if addend.is_a?(Money) && same_currency?(addend)

      raise TypeError, "#{addend} can't be added to #{self}"
    end

    def -(subtrahend)
      return self if subtrahend.respond_to?(:zero?) && subtrahend.zero?
      if subtrahend.is_a?(Money) && same_currency?(subtrahend)
        return mint(amount - subtrahend.amount)
      end

      raise TypeError, "#{subtrahend} can't be subtracted from #{self}"
    end

    def -@
      mint(-amount)
    end

    def *(multiplicand)
      return mint(amount * multiplicand.to_r) if multiplicand.is_a?(Numeric)

      raise TypeError, "#{self} can't be multiplied by #{multiplicand}"
    end

    def /(divisor)
      return mint(amount / divisor) if divisor.is_a?(Numeric)
      return amount / divisor.amount if same_currency? divisor

      raise TypeError, "#{self} can't be divided by #{divisor}"
    end
  end
end

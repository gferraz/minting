# frozen_string_literal: true

module Mint
  # :nodoc
  # Arithmetic functions for money ojects
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

    def +(addend)
      return mint(amount + addend.amount) if same_currency?(addend)
      return self unless addend.is_a?(Money) || addend.nonzero?

      raise TypeError, "#{addend} can't be added to #{self}"
    end

    def -(subtrahend)
      return self if subtrahend.zero?
      return mint(amount - subtrahend.amount) if same_currency?(subtrahend)

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

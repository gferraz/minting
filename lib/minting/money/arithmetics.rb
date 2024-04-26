# frozen_string_literal: true

module Mint
  # :nodoc
  # Arithmetic funcions for money ojects
  class Money
    def abs
      positive? ? self : mint(amount.abs)
    end

    def negative?
      amount.negative?
    end

    def positive?
      amount.positive?
    end

    def +(addend)
      return addend if zero?
      return self if addend.zero?
      return mint(amount + addend.amount) if same_currency?(addend)

      raise TypeError, "#{addend} can't be added to #{self}"
    end

    def -(subtrahend)
      return self if subtrahend.zero?
      return mint(amount - subtrahend.amount) if same_currency?(subtrahend)
      return -subtrahend if zero?

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

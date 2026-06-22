# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Performs addition with another {Money} instance or standard zero Numeric.
    #
    # @param addend [Money, Numeric] the value to add
    # @return [Money] the sum of the addition
    # @raise [TypeError] if addition involves a different currency or incompatible types
    def +(addend)
      case addend
      in 0 then self
      in Money if same_currency?(addend) then copy_with(amount: amount + addend.amount)
      else raise TypeError, "#{addend} can't be added to #{self}"
      end
    end

    # Performs subtraction with another {Money} instance or standard zero Numeric.
    #
    # @param subtrahend [Money, Numeric] the value to subtract
    # @return [Money] the difference of the subtraction
    # @raise [TypeError] if subtraction involves a different currency or incompatible types
    def -(subtrahend)
      case subtrahend
      when 0     then return self
      when Money then return copy_with(amount: amount - subtrahend.amount) if same_currency?(subtrahend)
      end
      raise TypeError, "#{subtrahend} can't be subtracted from #{self}"
    end

    # Unary negation operator. Returns a new {Money} instance with the inverted sign.
    #
    # @return [Money] negated Money instance
    def -@ = copy_with(amount: -amount)

    # Performs multiplication of the monetary value by a standard scalar Numeric.
    #
    # @param multiplicand [Numeric] the scalar multiplier
    # @return [Money] the multiplied Money instance
    # @raise [TypeError] if multiplier is not Numeric or is a Money object
    def *(multiplicand)
      raise TypeError, "#{self} can't be multiplied by #{multiplicand}" unless multiplicand.is_a?(Numeric)

      copy_with(amount: amount * multiplicand)
    end

    # Performs division of the monetary value by a scalar Numeric or identical currency {Money}.
    #
    # @param divisor [Numeric, Money] the divisor
    # @return [Money, Numeric] a new Money (scalar division) or a numeric ratio (Money division)
    # @raise [TypeError] if divisor is of incompatible type or different currency
    # @raise [ZeroDivisionError] if division by zero is attempted
    def /(divisor)
      case divisor
      when Numeric then return copy_with(amount: amount / divisor)
      when Money   then return amount / divisor.amount if same_currency? divisor
      end
      raise TypeError, "#{self} can't be divided by #{divisor}"
    end

    # Performs exponentiation of the monetary value by a standard scalar Numeric.
    #
    # @param exponent [Numeric]
    # @return [Money] reult of amount ** exponent
    # @raise [TypeError] if exponent is not Numeric
    def **(exponent)
      return copy_with(amount: amount**exponent) if exponent.is_a?(Numeric)

      raise TypeError, "#{self} can't be powered by #{exponent}"
    end
  end
end

module Mint
  class Money
    # Returns the absolute value of the monetary amount as a new {Money} instance.
    #
    # @return [Money] the absolute value
    def abs =     mint(amount.abs)

    # Returns true if the monetary amount is less than zero.
    #
    # @return [Boolean] true if negative, false otherwise
    def negative? = amount.negative?

    # Returns true if the monetary amount is greater than zero.
    #
    # @return [Boolean] true if positive, false otherwise
    def positive? = amount.positive?

    # Returns the successor of the Money instance by adding the minimum possible subunit amount.
    # Enables standard ranges and stepping (e.g. `1.dollar..10.dollars`).
    #
    # @return [Money] successor Money instance
    def succ = mint(amount + currency.minimum_amount)

    # Performs addition with another {Money} instance or standard zero Numeric.
    #
    # @param addend [Money, Numeric] the value to add
    # @return [Money] the sum of the addition
    # @raise [TypeError] if addition involves a different currency or incompatible types
    def +(addend)
      return self if addend.respond_to?(:zero?) && addend.zero?
      return mint(amount + addend.amount) if addend.is_a?(Money) && same_currency?(addend)

      raise TypeError, "#{addend} can't be added to #{self}"
    end

    # Performs subtraction with another {Money} instance or standard zero Numeric.
    #
    # @param subtrahend [Money, Numeric] the value to subtract
    # @return [Money] the difference of the subtraction
    # @raise [TypeError] if subtraction involves a different currency or incompatible types
    def -(subtrahend)
      return self if subtrahend.respond_to?(:zero?) && subtrahend.zero?
      if subtrahend.is_a?(Money) && same_currency?(subtrahend)
        return mint(amount - subtrahend.amount)
      end

      raise TypeError, "#{subtrahend} can't be subtracted from #{self}"
    end

    # Unary negation operator. Returns a new {Money} instance with the inverted sign.
    #
    # @return [Money] negated Money instance
    def -@
      mint(-amount)
    end

    # Performs multiplication of the monetary value by a standard scalar Numeric.
    #
    # @param multiplicand [Numeric] the scalar multiplier
    # @return [Money] the multiplied Money instance
    # @raise [TypeError] if multiplier is not Numeric or is a Money object
    def *(multiplicand)
      return mint(amount * multiplicand.to_r) if multiplicand.is_a?(Numeric)

      raise TypeError, "#{self} can't be multiplied by #{multiplicand}"
    end

    # Performs division of the monetary value by a scalar Numeric or identical currency {Money}.
    #
    # @param divisor [Numeric, Money] the divisor
    # @return [Money, Numeric] a new Money (scalar division) or a numeric ratio (Money division)
    # @raise [TypeError] if divisor is of incompatible type or different currency
    # @raise [ZeroDivisionError] if division by zero is attempted
    def /(divisor)
      return mint(amount / divisor) if divisor.is_a?(Numeric)
      return amount / divisor.amount if same_currency? divisor

      raise TypeError, "#{self} can't be divided by #{divisor}"
    end
  end
end

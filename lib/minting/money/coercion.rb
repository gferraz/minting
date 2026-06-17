# frozen_string_literal: true

module Mint
  # Implements the standard Ruby coercion protocol.
  class Money
    # Allows {Money} to interact seamlessly as the right-hand operand in Numeric arithmetic.
    # This enables expressions like `5 * money` where `5` is a Numeric and `money` is a Money object.
    #
    # @param other [Numeric] the left-hand operand to coerce
    # @return [Array(CoercedNumber, Money)] coerced operand array
    # @example
    #   price = Mint.money(10, 'USD')
    #   5 * price  #=> [USD 50.00] (via coercion)
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    # @private
    # Coerced Number contains the arithmetic logic for numeric compatible ops.
    # @private
    class CoercedNumber
      # @private
      def initialize(value) = @value = value

      # @private
      # Adds a CoercedNumber to a Money object.
      # Only zero is a valid additive identity (returns the Money unchanged).
      def +(other)
        raise_coercion_error(:+, other) unless @value.zero?

        other
      end

      # @private
      # Subtracts a Money object from a CoercedNumber.
      # Only zero is valid (returns the negated Money).
      def -(other)
        raise_coercion_error(:-, other) unless @value.zero?

        -other
      end

      # @private
      # Multiplies a Money object by the wrapped numeric value.
      # This is the standard coercion path for `Numeric * Money`.
      def *(other)
        other.copy_with(amount: @value * other.amount)
      end

      # @private
      # Divides a CoercedNumber by a Money object.
      # Not a meaningful operation (what currency is the result?).
      def /(other)
        raise_coercion_error(:/, other)
      end

      # @private
      # Only zero is dimensionless and comparable to Money.
      # e.g. 0 < price is meaningful; 0.5 < price is not (what currency is 0.5?).
      def <=>(other)
        return @value <=> other.amount if @value.zero? || other.zero?

        raise_coercion_error(:<=>, other)
      end

      private

      # Raises a TypeError with a descriptive message for unsupported coercions.
      def raise_coercion_error(operation, operand)
        raise TypeError, "#{@value} #{operation} #{operand} : incompatible operands"
      end
    end
    private_constant :CoercedNumber
  end
end

# frozen_string_literal: true

module Mint
  # Implements the standard Ruby coercion protocol.
  class Money
    # Allows {Money} to interact seamlessly as the right-hand operand in Numeric arithmetic.
    # This enables expressions like `5 + money` where `5` is a Numeric and `money` is a Money object.
    #
    # @param other [Numeric] the left-hand operand to coerce
    # @return [Array(CoercedNumber, Money)] coerced operand array
    # @example
    #   price = Mint.money(10, 'USD')
    #   5 + price  #=> [USD 15.00] (via coercion)
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    # @private
    # Coerced Number contains the arithmetic logic for numeric compatible ops.
    # @private
    class CoercedNumber
      # @private
      def initialize(value)
        @value = value
      end

      # @private
      def +(other)
        return other if @value.zero?

        raise_coercion_error(:+, other)
      end

      # @private
      def -(other)
        return -other if @value.zero?

        raise_coercion_error(:-, other)
      end

      # @private
      def *(other)
        other.mint(@value * other.amount)
      end

      # @private
      def /(other)
        raise_coercion_error(:/, other)
      end

      # Only zero is dimensionless and comparable to Money.
      # e.g. 0 < price is meaningful; 0.5 < price is not (what currency is 0.5?).
      def <=>(other)
        return @value <=> other.amount if @value.zero? || other.zero?

        raise_coercion_error(:<=>, other)
      end

      private

      def raise_coercion_error(operation, operand)
        raise TypeError,
              "#{@value} #{operation} #{operand} : incompatible operands"
      end
    end
    private_constant :CoercedNumber
  end
end

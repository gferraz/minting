module Mint
  class Money
    # Implements the standard Ruby coercion protocol.
    # Allows {Money} to interact seamlessly as the right-hand operand in Numeric arithmetic.
    #
    # @param other [Numeric] the left-hand operand to coerce
    # @return [Array(CoercedNumber, Money)] coerced operand array
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    # @private
    # Coerced Number contains the arithmetic logic for numeric compatible ops.
    # @private
    class CoercedNumber
      include Comparable

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

      # @private
      def <=>(other)
        return nil if @value.nil? || other.nil?
        return @value <=> other.amount if @value.zero? || other.zero?

        raise_coercion_error(:<=>, other)
      end

      # @private
      def raise_coercion_error(operation, operand)
        raise TypeError,
              "#{self} #{operation} #{operand} : incompatible operands"
      end
    end
  end
end

module Mint
  # :nodoc
  # Coercion logic
  class Money
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    # :nodoc
    # Coerced Number contains the arithmetic logic for numeric compatible ops.
    class CoercedNumber
      include Comparable

      def initialize(value)
        @value = value
      end

      def +(other)
        return other if @value.zero?

        raise_coercion_error(:+, other)
      end

      def -(other)
        return -other if @value.zero?

        raise_coercion_error(:-, other)
      end

      def *(other)
        other.mint(@value * other.amount)
      end

      def /(other)
        raise_coercion_error(:/, other)
      end

      def <=>(other)
        return nil if @value.nil? || other.nil?
        return @value <=> other.amount if @value.zero? || other.zero?

        raise_coercion_error(:<=>, other)
      end

      def raise_coercion_error(operation, operand)
        raise TypeError,
              "#{self} #{operation} #{operand} : incompatible operands"
      end
    end
  end
end

class Mint
  # :nodoc
  class Money
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    private

    def raise_coercion_error(operation, operand)
      raise TypeError, "#{self} #{operation} #{operand} : incompatible operands"
    end

    # :nodoc
    class CoercedNumber
      include Comparable

      def initialize(value)
        @value = value.to_r
      end

      def *(other)
        other.mint(@value * other.amount)
      end

      def +(other)
        raise_coercion_error(:+, other) unless @value.zero?
        other.mint(@value + other.amount)
      end

      def -(other)
        raise_coercion_error(:-, other) unless @value.zero?
        other.mint(@value - other.amount)
      end

      def <=>(other)
        raise_coercion_error(:<=>, other) unless @value.zero? || other.zero?
        @value <=> other.amount
      end

      def raise_coercion_error(operation, operand)
        raise TypeError, "#{self} #{operation} #{operand} : incompatible operands"
      end
    end
  end
end

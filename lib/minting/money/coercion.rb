class Mint
  class Money
    def coerce(other)
      [CoercedNumber.new(other), self]
    end

    private

    def coerced_operation(operation, object)
      result = nil
      if !object.is_a?(Mint::Money) && object.respond_to?(:coerce)
        op1, op2 = object.coerce(self)
        result = op1 && op1.send(operation, op2)
      end
      result
    end

    def raise_coercion_error(operation, operand)
      raise TypeError, "#{self} #{operation} #{operand} : incompatible operands"
    end

    class CoercedNumber
      include Comparable

      def initialize(value)
        @value = value.to_r
      end

      def *(other)
        other.mint(@value * other.to_r)
      end

      def +(other)
        raise_coercion_error(:+, other) unless @value.zero?
        other.mint(@value + other.to_r)
      end

      def -(other)
        raise_coercion_error(:-, other) unless @value.zero?
        other.mint(@value - other.to_r)
      end

      def <=>(other)
        raise_coercion_error(:<=>, other) unless @value.zero? || other.zero?
        @value <=> other.to_r
      end

      def raise_coercion_error(operation, operand)
        raise TypeError, "#{self} #{operation} #{operand} : incompatible operands"
      end
    end
  end
end

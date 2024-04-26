# frozen_string_literal: true

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
        @value = value.to_r
      end

      def +(other)
        raise_coercion_error(:+, other) if @value.nonzero?
        other.mint(@value + other.amount)
      end

      def -(other)
        raise_coercion_error(:-, other)
      end

      def *(other)
        other.mint(@value * other.amount)
      end

      def /(other)
        other.mint(@value / other.amount)
      end

      def <=>(other)
        raise_coercion_error(:<=>, other) if !@value.zero? && other.nonzero?
        @value <=> other.amount
      end

      def raise_coercion_error(operation, operand)
        raise TypeError,
              "#{self} #{operation} #{operand} : incompatible operands"
      end
    end
  end
end

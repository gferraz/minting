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
      operation(:+, addend) do
        if addend.zero?
          self
        elsif zero?
          addend
        elsif currency == addend.currency
          mint(amount + addend.amount)
        end
      end
    end

    def -(subtrahend)
      operation(:-, subtrahend) do
        if subtrahend.zero?
          self
        elsif currency == subtrahend.currency
          mint(amount - subtrahend.amount)
        end
      end
    end

    def -@
      zero? ? self : mint(-amount)
    end

    def *(multiplicand)
      operation(:*, multiplicand) do
        return mint(0r) if multiplicand.zero?

        case multiplicand
        when Numeric
          mint(amount * multiplicand.to_r)
        when Money
          raise TypeError, "#{self} can't be multiplied by #{multiplicand}"
        end
      end
    end

    def /(divisor)
      operation(:/, divisor) do
        case divisor
        when Numeric
          mint(amount / divisor)
        when Money
          amount / divisor.amount if currency == divisor.currency
        else
          raise TypeError, "#{self} can't be divided by #{divisor}"
        end
      end
    end

    private

    def coerced_operation(operation, object)
      first_operand, second_operand = object.coerce(self)
      result = first_operand&.send(operation, second_operand)
      result || raise(TypeError, "#{operand} can't be coerced into #{self.class}")
    end

    def operation(operator, operand)
      yield || coerced_operation(operator, operand)
    rescue NoMethodError
      raise_coercion_error(operator, operand)
    end
  end
end

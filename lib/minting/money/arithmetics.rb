class Mint
  # :nodoc
  class Money
    def abs
      negative? ? mint(@amount.abs) : self
    end

    def negative?
      @amount.negative?
    end

    def positive?
      @amount.positive?
    end

    def +(other)
      operation(:+, other) do
        if other.zero?
          self
        elsif zero?
          other
        elsif currency == other.currency
          mint(@amount + other.amount)
        end
      end
    end

    def -(other)
      operation(:-, other) do
        if other.zero?
          self
        elsif zero?
          other.mint(-other.amount)
        elsif currency == other.currency
          mint(@amount - other.amount)
        end
      end
    end

    def -@
      zero? ? self : mint(-@amount)
    end

    def *(other)
      operation(:*, other) do
        if other.zero?
          mint(0r)
        elsif other.is_a? Numeric
          mint(@amount * other.to_r)
        end
      end
    end

    def /(other)
      operation(:/, other) do
        raise ZeroDivisionError, "#{self} can't be divided by zero" if other.zero?
        case other
        when Numeric
          mint(@amount / other.to_r)
        when Money
          @amount / other.amount if currency == other.currency
        end
        # raise TypeError, "#{self} can't be divided by #{other}"
      end
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

    def operation(operator, operand)
      val = nil
      begin
        val = yield
        val ||= coerced_operation(operator, operand)
        val || raise(TypeError, "#{operand.class} can't be coerced into #{self.class}")
      rescue NoMethodError
        raise_coercion_error(operator, operand)
      end
      val
    end
  end
end

class Mint
  # :nodoc
  class Money
    def +(other)
      operation(:+, other) do
        if other.zero?
          self
        elsif zero?
          other
        elsif currency == other.currency
          mint(to_r + other.to_r)
        end
      end
    end

    def -(other)
      operation(:-, other) do
        if other.zero?
          self
        elsif currency == other.currency
          mint(to_r - other.to_r)
        end
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

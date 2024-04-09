class Mint
  # :nodoc
  # Comparision methods
  class Money
    include Comparable

    # @return true if both are zero, or both have same amount and same currency
    def ==(other)
      case other
      when Numeric
        return true if zero? && other.zero?
      when Mint::Money
        return false if nonzero? && currency != other.currency
        return true if amount == other.amount
      end
      false
    end

    # @example
    #   two_usd == Mint::Money.new(2r, Currency[:USD]) #=> [$ 2.00]
    #   two_usd > 0                                    #=> true
    #   two_usd > Mint::Money.new(1r, Currency[:USD])  #=> true
    #   two_usd > 1                                    #=> TypeError: [$ 2.00] can't be compared to 1
    #   two_usd > Mint::Money.new(2, Currency[:BRL])   #=> TypeError: [$ 2.00] can't be compared to [R$ 2.00]
    #
    def <=>(other)
      case other
      when Numeric
        return 0 if zero? && other.zero?
      when Mint::Money
        return amount <=> other.amount if currency == other.currency
      end
      raise TypeError, "#{self} can't be compared to #{other}"
    end

    def eql?(other)
      self == other
    end

    def hash
      @hash ||= zero? ? 0.hash : [amount, currency].hash
    end

    def nonzero?
      amount.nonzero?
    end

    def zero?
      amount.zero?
    end
  end
end

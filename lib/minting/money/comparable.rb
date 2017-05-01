class Mint
  class Money
    include Comparable

    # @return true if both are zero, or both have same amount and same currency
    def ==(other)
      @amount.zero? && other.respond_to?(:zero?) && other.zero? ||
        other.is_a?(Money) && @amount == other.amount && @currency == other.currency
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
        other_amount = other
        other_currency = nil
      when Mint::Money
        other_amount = other.amount
        other_currency = other.currency
      else
        raise TypeError, "#{other.class} can't be compared to #{self.class}"
      end
      if zero? || other.zero? || currency == other_currency
        @amount <=> other_amount
      else
        raise TypeError, "#{self} can't be compared to #{other}"
      end
    end
  end
end

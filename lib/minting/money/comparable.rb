# frozen_string_literal: true

module Mint
  # Comparison methods
  class Money
    include Comparable

    # @return true if both are zero, or both have same amount and same currency
    def ==(other)
      return true if zero? && other.respond_to?(:zero?) && other.zero?

      eql?(other)
    end

    def eql?(other)
      other.is_a?(Mint::Money) &&
        amount == other.amount &&
        currency == other.currency
    end

    # @example
    #   two_usd == Mint.money(2r, 'USD') #=> [$ 2.00]
    #   two_usd > 0                      #=> true
    #   two_usd > Mint.money(2, 'USD')   #=> false
    #   two_usd > 1
    #   => TypeError: [$ 2.00] can't be compared to 1
    #   two_usd > Mint.money(2, 'BRL')
    #   => TypeError: [$ 2.00] can't be compared to [R$ 2.00]
    #
    def <=>(other)
      case other
      in 0                                    then amount <=> other
      in Mint::Money if same_currency?(other) then amount <=> other.amount
      else                                    raise TypeError, "#{inspect} can't be compared to #{other.inspect}"
      end
    end

    def nonzero? = amount.nonzero?

    def zero? = amount.zero?
  end
end

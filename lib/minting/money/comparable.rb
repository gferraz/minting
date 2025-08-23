# frozen_string_literal: true

module Mint
  # :nodoc
  # Comparison methods
  class Money
    include Comparable

    # @return true if both are zero, or both have same amount and same currency
    def ==(other)
      return true if other.is_a?(Numeric) && zero? && other.zero?
      return false unless other.is_a?(Mint::Money)
      return false if nonzero? && currency != other.currency

      amount == other.amount
    end

    # @example
    #   two_usd == Mint.money(2r, 'USD']) #=> [$ 2.00]
    #   two_usd > 0                       #=> true
    #   two_usd > Mint.money(2, 'USD'])  #=> true
    #   two_usd > 1
    #   => TypeError: [$ 2.00] can't be compared to 1
    #   two_usd > Mint.money(2, 'BRL'])
    #   => TypeError: [$ 2.00] can't be compared to [R$ 2.00]
    #
    def <=>(other)
      case other
      when Numeric
        return amount <=> other if other.zero?
      when Mint::Money
        return amount <=> other.amount if currency == other.currency
      end
      raise TypeError, "#{inspect} can't be compared to #{other.inspect}"
    end

    def eql?(other)
      self == other
    end

    def nonzero?
      amount.nonzero?
    end

    def zero?
      amount.zero?
    end
  end
end

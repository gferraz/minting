# frozen_string_literal: true

module Mint
  # Comparison methods
  class Money
    include Comparable

    # @return true if both are zero, or both have same amount and same currency
    def ==(other)
      case other
      when 0           then zero?
      when Mint::Money then amount == other.amount && currency == other.currency
      else                  false
      end
    end

    # Strict equality — both amount and currency must match exactly.
    # Unlike ==, does not treat zero as equivalent across currencies.
    #
    # @return [Boolean]
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

    # @return [self, nil] self if amount is non-zero, nil otherwise
    def nonzero? = amount.nonzero?

    # @return [Boolean] true if amount is zero
    def zero? = amount.zero?
  end
end

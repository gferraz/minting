# frozen_string_literal: true

module Mint
  # Money clamp
  class Money
    # Constrains +self+ to the inclusive range [+min+, +max+].
    #
    # Bounds may be:
    # - nil meaning no boundary
    # - same-currency {Money} or Range
    # - Numeric amount, or Range
    #
    # Numeric is interpreted as an amount in +self+'s currency, so the common
    # pricing idiom +price.clamp(0, 100)+ reads as "0 to 100 in the same
    # currency as +price+".
    #
    # When +self+ is already in range the receiver is returned (no new object
    # allocated). When out of range, the nearest bound is returned as a new
    # frozen {Money} in +self+'s currency.
    #
    # @param min_or_range [Money, Numeric, Range, nil] lower bound (inclusive), or range
    # @param max [Money, Numeric, nil] upper bound (inclusive)
    # @return [Money] +self+ if in range, otherwise the nearer bound
    # @raise [ArgumentError] if +min+ or +max+ is not a Money, Numeric or nil; if
    #   a Money operand has a different currency; if +min+ > +max+;
    #   if min is a Range, and max is not nil
    #
    # @example In range
    #   Mint.money(5, 'USD').clamp(0, 10) #=> [USD 5.00]  (returns self)
    #
    # @example Out of range, with Numeric bounds
    #   Mint.money(50, 'USD').clamp(0, 10) #=> [USD 10.00]
    #
    # @example Out of range, with Money bounds
    #   loss  = Mint.money(-5, 'USD')
    #   floor = Mint.money(0,  'USD')
    #   ceil  = Mint.money(10, 'USD')
    #   loss.clamp(floor, ceil) #=> [USD 0.00]
    #
    # @example Subunit-0 currency (JPY)
    #   Mint.money(500, 'JPY').clamp(0, 100) #=> [JPY 100]
    def clamp(min_or_range, max = nil)
      if min_or_range.is_a?(Range)
        raise(ArgumentError, "Either amount range alone or two amounts accepted: #{max}") if max

        min, max = min_or_range.minmax
      else
        min = min_or_range
      end
      copy_with(amount: amount.clamp(normalize_boundary(min), normalize_boundary(max)))
    end

    private

    # Converts a clamp boundary to a numeric amount.
    # @private
    def normalize_boundary(boundary)
      case boundary
      in NilClass | Numeric                then boundary
      in Money if same_currency?(boundary) then boundary.amount
      in Money                             then raise ArgumentError, "oundary currency must be: #{currency_code}"
      else                                 raise ArgumentError, "Boundary must be Numeric or Money #{boundary}"
      end
    end
  end
end

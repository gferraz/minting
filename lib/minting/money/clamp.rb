# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Constrains +self+ to the inclusive range [+min+, +max+].
    #
    # Bounds may be:
    # - nil meaning no boundary
    # - same-currency {Money} or Range
    #
    # When +self+ is already in range the receiver is returned (no new object
    # allocated). When out of range, the nearest bound is returned as a new
    # frozen {Money} in +self+'s currency.
    #
    # @param min_or_range [Money, Range, nil] lower bound (inclusive), or range
    # @param max [Money, nil] upper bound (inclusive)
    # @return [Money] +self+ if in range, otherwise the nearer bound
    # @raise [ArgumentError] if +min+ or +max+ is not a Money or nil; if
    #   a Money operand has a different currency; if +min+ > +max+;
    #   if min is a Range, and max is not nil
    #
    # @example In range
    #   Money.from(5, 'USD').clamp(Money.from(0, 'USD'), Money.from(10, 'USD')) #=> [USD 5.00]  (returns self)
    #
    # @example Out of range, with Money bounds
    #   loss  = Money.from(-5, 'USD')
    #   floor = Money.from(0,  'USD')
    #   ceil  = Money.from(10, 'USD')
    #   loss.clamp(floor, ceil) #=> [USD 0.00]
    #
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
      in NilClass                           then boundary
      in Money if same_currency?(boundary) then boundary.amount
      in Money                             then raise ArgumentError, "Boundary currency must be: #{currency_code}"
      else                                 raise ArgumentError, "Boundary must be Money or nil: #{boundary}"
      end
    end
  end
end

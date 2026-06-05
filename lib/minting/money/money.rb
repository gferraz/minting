# frozen_string_literal: true

module Mint
  # Money constructors
  class Money
    # The default display format pattern for formatting monetary values.
    # Uses `%<symbol>s` for the currency symbol and `%<amount>f` for the rounded amount.
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    attr_reader :amount, :currency

    # Returns the ISO 3-letter currency code string.
    #
    # @return [String] the ISO currency code
    def currency_code = currency.code

    def fractional = (amount * currency.fractional_multiplier).to_i

    # Generates a stable hash key for Money instances.
    #
    # @return [Integer] the calculated hash value
    def hash = [amount, currency_code].hash

    # Returns a standard developer-oriented string inspection of the Money object.
    #
    # @return [String] the formatted inspect representation
    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", amount
    end

    # Helper method to verify if another object has the identical currency.
    #
    # @param other [Currency] the target currency to compare
    # @return [Boolean] true if currencies match, false otherwise
    def same_currency?(other) = other.currency == currency

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

      case min
      when Money
        raise(ArgumentError, "min currency must be: #{currency_code}") unless same_currency?(min)

        min = min.amount
      when NilClass # noop
      when Numeric # noop
      else
        raise(ArgumentError, "min must be Numeric or Money #{min}")
      end

      case max
      when Money
        raise(ArgumentError, "max currency must be: #{currency_code}") unless same_currency?(max)

        max = max.amount
      when NilClass # noop
      when Numeric # noop
      else
        raise(ArgumentError, "max must be Numeric or Money #{max}")
      end

      mint(amount.clamp(min, max))
    end
  end
end

# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Splits the monetary amount into a given quantity of equal parts.
    # Disperses any fractional subunit rounding differences across the initial slots
    # so that the sum is preserved.
    #
    # @param slices [Integer] the number of equal parts to divide the money into (must be > 0)
    # @return [Array<Money>] the list of newly split Money objects
    # @raise [ArgumentError] if quantity is not a positive integer
    #
    # @example Even split
    #   money = Mint.money(10.00, 'USD')
    #   money.split(3) #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
    def split(slices)
      raise ArgumentError, 'Slices quantity must be an poitive integer' unless slices.positive? && slices.integer?

      fraction = currency.normalize_amount(amount / slices)
      allocate_left_over(amounts: Array.new(slices, fraction),
                         left_over: amount - (fraction * slices))
    end

    private

    # Distributes any leftover amount across the allocation slots by adjusting
    # individual amounts by the currency's minimum unit, and converting to Money.
    # Caution: amounts array is mutated by this method
    # @private
    def allocate_left_over(amounts:, left_over:)
      if left_over.nonzero?
        minimum = currency.minimum_amount
        minimum = -minimum if left_over.negative?
        slots_to_adjust = (left_over / minimum).to_i
        (0...slots_to_adjust).each { |slot| amounts[slot] += minimum }
      end
      amounts.map! { |amount| Money.new(amount, currency) }
    end
  end
end

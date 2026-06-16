# frozen_string_literal: true

module Mint
  # Allocation and splitting
  class Money
    # Proportionally allocates the monetary amount among a list of ratios.
    # Disperses any subunit rounding amounts across the initial slots
    # @param proportions [Array<Numeric>] a list of numeric proportions/ratios to allocate by
    # @return [Array<Money>] the list of newly allocated Money objects
    # @raise [ArgumentError] if the proportions list is empty or sums to zero
    #
    # @example Proportional allocation
    #   money = Mint.money(10.00, 'USD')
    #   money.allocate([1, 2, 3]) #=> [[USD 1.67], [USD 3.33], [USD 5.00]]
    def allocate(proportions)
      whole = proportions.sum.to_r
      raise ArgumentError, 'Need at least 1 proportion element' if proportions.empty?
      raise ArgumentError, 'Proportions total must not be zero' if whole.zero?

      amounts = proportions.map { |rate| currency.normalize_amount(Rational(amount * rate, whole)) }
      allocate_left_over(amounts: amounts, left_over: amount - amounts.sum)
    end
  end
end

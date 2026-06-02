module Mint
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

      subunit = currency.subunit
      amounts = proportions.map { |rate| (amount * rate.to_r / whole).round(subunit) }
      allocate_left_over!(amounts: amounts, left_over: amount - amounts.sum)
    end

    # Splits the monetary amount into a given quantity of equal parts.
    # Disperses any fractional subunit rounding differences across the initial slots
    # so that the sum is preserved.
    #
    # @param quantity [Integer] the number of equal parts to divide the money into (must be > 0)
    # @return [Array<Money>] the list of newly split Money objects
    # @raise [ArgumentError] if quantity is not a positive integer
    #
    # @example Even split
    #   money = Mint.money(10.00, 'USD')
    #   money.split(3) #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
    def split(quantity)
      unless  quantity.positive? && quantity.integer?
        raise ArgumentError,
              'quantity must be an integer > 0'
      end

      fraction = (amount / quantity).round(currency.subunit)
      allocate_left_over!(amounts: Array.new(quantity, fraction),
                          left_over: amount - (fraction * quantity))
    end

    private

    def allocate_left_over!(amounts:, left_over:)
      if left_over.nonzero?
        minimum = left_over.positive? ? currency.minimum_amount : -currency.minimum_amount
        last_slot = (left_over / minimum).to_i - 1
        (0..last_slot).each { |slot| amounts[slot] += minimum }
      end
      amounts.map { Money.new(it, currency) }
    end
  end
end

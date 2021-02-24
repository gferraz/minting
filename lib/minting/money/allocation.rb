class Mint
  # :nodoc
  class Money
    def allocate(proportions)
      raise ArgumentError, 'Need at least 1 proportion element' if proportions.empty?

      whole = proportions.sum.to_r
      allocation = proportions.map { |rate| mint(amount * rate.to_r / whole) }

      allocate_left_over(allocation, self - allocation.sum)
    end

    def split(quantity)
      raise ArgumentError, 'quantitity must be an integer > 0' unless quantity.positive? && quantity.integer?

      fraction = self / quantity
      allocation = Array.new(quantity, fraction)

      allocate_left_over(allocation, self - fraction * quantity)
    end

    private

    def allocate_left_over(allocation, left_over)
      minimum = mint(left_over.positive? ? currency.minimum_amount : -currency.minimum_amount)

      slots = (left_over / minimum).to_i - 1
      (0..slots).each { |i| allocation[i] += minimum }

      allocation
    end
  end
end

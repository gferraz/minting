
class Mint
  class Money

    def allocate(proportions)
      whole = proportions.sum.to_r
      allocation = proportions.map {|rate| mint(amount * rate.to_r  / whole) }
      difference = self - allocation.sum

      allocate_left_over(allocation, difference)
    end

    def split(quantity)
      raise ArgumentError, 'quantitity must be an integer > 0' unless quantity.positive? && quantity.integer?

      fraction = self / quantity
      allocation = Array.new(quantity, fraction)
      difference = self - fraction * quantity

      allocate_left_over(allocation, difference)
    end

    private

    def allocate_left_over(allocation, difference)
      remaining = self - allocation.sum
      minimum = mint(remaining.positive? ? currency.minimum : -currency.minimum)

      slots = (remaining / minimum).to_i - 1
      (0..slots).each { |i| allocation[i] += minimum }

      allocation
    end

  end
end

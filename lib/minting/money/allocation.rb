# frozen_string_literal: true

module Mint
  # :nodoc
  class Money
    def allocate(proportions)
      raise ArgumentError, 'Need at least 1 proportion element' if proportions.empty?

      whole = proportions.sum.to_r
      allocation = proportions.map { |rate| mint(amount * rate.to_r / whole) }
      left_over =  self - allocation.sum
      allocate_left_over(allocation, left_over)
    end

    def split(quantity)
      unless quantity.positive? && quantity.integer?
        raise ArgumentError,
              'quantitity must be an integer > 0'
      end

      fraction = self / quantity
      allocation = Array.new(quantity, fraction)
      left_over = self - (fraction * quantity)
      allocate_left_over(allocation, left_over)
    end

    private

    def allocate_left_over(allocation, left_over)
      minimum = currency.minimum_amount
      minimum = mint(left_over.positive? ? minimum : -minimum)

      slots = (left_over / minimum).to_i - 1
      (0..slots).each { |slot| allocation[slot] += minimum }
      allocation
    end
  end
end

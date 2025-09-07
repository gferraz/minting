module Mint
  # :nodoc
  # split and allocation methods
  class Money
    def allocate(proportions)
      raise ArgumentError, 'Need at least 1 proportion element' if proportions.empty?

      whole = proportions.sum.to_r
      amounts = proportions.map! { |rate| (amount * rate.to_r / whole).round(currency.subunit) }
      allocate_left_over!(amounts: amounts, left_over: amount - amounts.sum)
    end

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
      amounts.map { mint(it) }
    end
  end
end

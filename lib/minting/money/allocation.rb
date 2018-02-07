
class Mint
  class Money
    def split(quantity)
      raise ArgumentError, 'quantitity must be an integer > 0' unless quantity.positive? && quantity.integer?

      fraction = self / quantity
      parts = Array.new(quantity, fraction)

      remaining = self - fraction * quantity

      minimum = 10r ** -currency.subunit
      minimum *= -1 if remaining.negative?
      minimum = mint(minimum)
      
      fraction += minimum

      slots = (remaining / minimum).to_i - 1
      (0..slots).each { |i| parts[i] = fraction }
      parts
    end
  end
end

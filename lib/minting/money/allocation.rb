
class Mint
  class Money

    def split(quantity)
      quantity = quantity.to_i
      fraction = self / quantity
      parts = Array.new(quantity) { fraction }
      parts[0] += self - fraction * quantity
      parts 
    end
  end
end

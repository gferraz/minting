# Mint is a library to operate with monetary values
module Mint
  refine Numeric do
    def reais
      Mint.money(self, 'BRL')
    end

    def dollars
      Mint.money(self, 'USD')
    end

    def euros
      Mint.money(self, 'EUR')
    end

    def to_money(currency)
      Mint.money(self, currency)
    end

    alias_method :dollar, :dollars
    alias_method :euro, :euros
    alias_method :mint, :to_money
  end

  refine String do
    def to_money(currency)
      Mint.money(to_r, currency)
    end
  end
end

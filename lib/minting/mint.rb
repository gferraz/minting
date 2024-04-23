module Mint
  def self.currency(code)
    CurrencyDirectory[code]
  end

  def self.money(amount, currency)
    Money.new(amount, CurrencyDirectory[currency])
  end

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

    alias dollar dollars
    alias real reais
    alias euro euros
  end
end

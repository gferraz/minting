# Mint is a library to operate with monetary values
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

    def to_money(currency)
      Mint.money(self, currency)
    end

    alias_method :dollar, :dollars
    alias_method :real, :reais
    alias_method :euro, :euros
    alias_method :mint, :to_money
    alias_method :real, :reais
  end

  refine String do
    def to_money(currency)
      Mint.money(to_r, currency)
    end
  end
end

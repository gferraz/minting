module Mint
  def self.currency(code)
    CurrencyDirectory[code]
  end

  def self.money(amount, currency)
    Money.new(amount, CurrencyDirectory[currency])
  end
end

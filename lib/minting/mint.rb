class Mint
  def self.currency(code)
    CurrencyDirectory[code]
  end

  attr_reader :currency, :currency_code

  def initialize(currency)
    @currency = CurrencyDirectory[currency]
    raise KeyError, 'No currency found' unless @currency

    @currency_code = @currency.code
  end

  def self.money(amount, currency)
    Money.new(amount, CurrencyDirectory[currency])
  end

  def money(amount)
    amount.zero? ? zero : Money.new(amount.to_r, currency)
  end

  def zero
    @zero ||= Money.new(0r, currency)
  end

  def minimum
    @minimum ||= Money.new(currency.minimum_amount, currency)
  end

  def inspect
    "<Mint:#{currency_code}>"
  end
end

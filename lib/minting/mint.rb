
class Mint
  attr_reader :currency
  attr_reader :currency_code

  def initialize(currency)
    @currency = Currency[currency]
    raise KeyError, 'No currency found' unless @currency
    @currency_code = @currency.code
  end

  def inspect
    "<Mint:#{currency_code}>"
  end
end

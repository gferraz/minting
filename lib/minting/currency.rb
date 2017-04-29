require 'irb'
class Currency
  def self.[](currency)
    return currency if currency.is_a? Currency
    currencies[currency.to_s] || currencies[nil]
  end

  def self.currencies
    @currencies ||= {}
  end

  def self.register(code, subunit:, symbol: nil)
    code = code.to_s
    currencies[code] || register!(code, subunit: subunit.to_i, symbol: symbol || code)
  end

  def self.register!(code, subunit:, symbol: nil)
    code = code.to_s
    raise ArgumentError, "Currency code must be a 3 letter String or Symbol ('USD', :EUR)" unless code =~ /^[A-Z]{3}$/
    raise KeyError,      "Currency: #{code} already registered"                            if currencies[code]
    currencies[code] = Currency.new(code, subunit: subunit.to_i, symbol: symbol || code)
  end

  attr_reader :code
  attr_reader :subunit
  attr_reader :symbol

  def inspect
    "<Currency:(#{code} #{symbol} #{subunit})>"
  end

  private

  def initialize(code, subunit:, symbol:)
    @code = code
    @subunit = subunit
    @symbol = symbol
  end
end

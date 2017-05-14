
class Mint
  class Formatter
    Options = Struct.new(:delimiter, :precision, :separator, :symbol)

    def initialize(&block)
      @block = block
    end

    def format(money, delimiter: nil, precision: nil, separator: nil, symbol: nil)
      options = Options.new(delimiter, precision, separator, symbol || money.currency.symbol)
      @block.call(money, options)
    end
  end
end

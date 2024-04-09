class Mint
  # :nodoc
  # String formating for money objects
  class Formatter
    def self.[](name)
      formatters[name]
    end

    def self.formatters
      @formatters ||= {}
    end

    def self.register(name, &block)
      formatters[name] || register!(name, &block)
    end

    def self.register!(name, &block)
      raise KeyError, "#{name} formatter already registered" if formatters[name]

      formatters[name] = Formatter.new(&block)
    end

    def initialize(&block)
      @block = block
    end

    def format(money:, delimiter: nil, precision: nil, separator: '.', symbol: money.currency.symbol)
      options = Data.define(:delimiter, :precision, :separator, :symbol).new(delimiter, precision, separator, symbol)
      @block.call(money, options)
    end
  end
end

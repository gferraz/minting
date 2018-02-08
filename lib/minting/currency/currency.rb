class Mint
  class Currency
    attr_reader :code
    attr_reader :subunit
    attr_reader :symbol

    def format(amount, format: '')
      amount = amount.amount if amount.is_a?(Mint::Money)

      format = format.empty? ? '%<symbol>s%<amount>f' : format.dup
      format.gsub!(/%<amount>(\+?\d*)f/, "%<amount>\\1.#{subunit}f")

      verbosity = $VERBOSE
      # $VERBOSE = false
      formatted = Kernel.format(format, amount: amount, currency: code, symbol: symbol)
      $VERBOSE = verbosity
      formatted
    end

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit})>"
    end

    def minimum
      @minimum ||= 10r ** -subunit
    end

    private

    def initialize(code, subunit:, symbol:)
      @code = code
      @subunit = subunit
      @symbol = symbol
    end
  end
end

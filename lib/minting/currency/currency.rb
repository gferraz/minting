class Mint
  class Currency
    attr_reader :code, :subunit, :symbol

    def canonical_format(amount)
      Kernel.format("#{code} %0.#{subunit}f", amount)
    end

    def format(amount, format: '')
      amount = amount.amount if amount.is_a?(Mint::Money)

      format = format.empty? ? '%<symbol>s%<amount>f' : format.dup
      format.gsub!(/%<amount>(\+?\d*)f/, "%<amount>\\1.#{subunit}f")

      Kernel.format(format, amount: amount, currency: code, symbol: symbol)
    end

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit})>"
    end

    def minimum_amount
      @minimum_amount ||= 10r**-subunit
    end

    private

    def initialize(code, subunit:, symbol:)
      @code = code
      @subunit = subunit
      @symbol = symbol
    end
  end
end

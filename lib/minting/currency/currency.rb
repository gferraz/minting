module Mint
  class Currency
    attr_reader :code, :subunit, :symbol

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

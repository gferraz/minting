module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
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

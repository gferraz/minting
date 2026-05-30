module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  class Currency
    attr_reader :code, :subunit, :symbol, :priority, :minimum_amount, :country, :name

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit})>"
    end

    private

    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil)
      @code = code.to_s
      @subunit = subunit.to_i
      @symbol = symbol
      @priority = priority.to_i
      @country = country
      @name = name
      @minimum_amount = 10r**-@subunit
      freeze
    end
  end
end

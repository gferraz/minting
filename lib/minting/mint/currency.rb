module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  class Currency
    attr_reader :code, :subunit, :symbol, :users, :minimum_amount

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit})>"
    end

    private

    def initialize(code, subunit:, symbol:, users: 0)
      @code = code.to_s
      @subunit = subunit.to_i
      @symbol = symbol.to_s
      @users = users.to_i
      @minimum_amount = 10r**-subunit
      freeze
    end
  end
end

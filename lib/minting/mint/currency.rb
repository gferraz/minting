# frozen_string_literal: true

module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  class Currency
    attr_reader :code, :subunit, :symbol,
                :country,
                :fractional_multiplier, :minimum_amount,
                :name, :priority

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit})>"
    end

    def normalize_amount(amount)
      amount.to_r.round(subunit)
    end

    private

    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil)
      @code = code
      @subunit = subunit.to_i
      @symbol = symbol
      @priority = priority.to_i
      @country = country
      @name = name
      @fractional_multiplier = 10**@subunit
      @minimum_amount = 1r / fractional_multiplier
      freeze
    end
  end
end

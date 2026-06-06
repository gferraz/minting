# frozen_string_literal: true

module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  Currency = Data.define(:code, :subunit, :symbol, :priority, :country, :name,
                         :fractional_multiplier, :minimum_amount) do
    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil)
      subunit = subunit.to_i
      priority = priority.to_i
      fractional_multiplier = 10**subunit
      minimum_amount = Rational(1, fractional_multiplier)
      super(code:, subunit:, symbol:, priority:, country:, name:,
            fractional_multiplier:, minimum_amount:)
    end

    def ==(other) = code == other.code

    def inspect
      "<Currency:(#{code} #{symbol} #{subunit} #{name})>"
    end

    # Normalizes numeric amounts for this currency
    # 1. Converts to Rational
    # 2. Rounds to respect currency subunit
    def normalize_amount(amount) = amount.to_r.round(subunit)
  end
end

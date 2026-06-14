# frozen_string_literal: true

module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code.
  # Currency objects are immutable and define the properties of a monetary unit
  # including its subunit precision, display symbol, and formatting rules.
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  # @attr_reader code [String] ISO 4217 currency code (e.g., "USD", "EUR")
  # @attr_reader subunit [Integer] Number of decimal places (0 for JPY, 2 for USD, 3 for IQD)
  # @attr_reader symbol [String] Display symbol (e.g., "$", "€", "R$")
  # @attr_reader priority [Integer] Parser precedence for symbol detection
  # @attr_reader country [String, nil] Associated country code
  # @attr_reader name [String, nil] Currency name
  # @attr_reader fractional_multiplier [Integer] 10^subunit, used for fractional conversions
  # @attr_reader minimum_amount [Rational] Smallest representable amount (1/fractional_multiplier)
  Currency = Data.define(:code, :subunit, :symbol, :priority, :country, :name,
                         :fractional_multiplier) do
    # @param code [String] ISO 4217 currency code
    # @param symbol [String] Display symbol
    # @param subunit [Integer] Number of decimal places (default 0)
    # @param priority [Integer] Parser precedence for symbol detection (default 0)
    # @param country [String, nil] Associated country code (default nil)
    # @param name [String, nil] Currency name (default nil)
    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil)
      subunit = subunit.to_i
      priority = priority.to_i
      fractional_multiplier = 10**subunit
      super(code:, subunit:, symbol:, priority:, country:, name:,
            fractional_multiplier:)
    end

    # @return [String] debug representation
    def inspect = "<Currency:(#{code} #{symbol} #{subunit} #{name})>"

    # @return [Rational] smallest representable amount (1/fractional_multiplier)
    def minimum_amount = Rational(1, fractional_multiplier)

    # Normalizes numeric amounts for this currency
    # 1. Converts to Rational
    # 2. Rounds to respect currency subunit
    def normalize_amount(amount) = amount.to_r.round(subunit)
  end
end

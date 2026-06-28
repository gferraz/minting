# frozen_string_literal: true

# Core extension: adds money-parsing helper to String.
class String
  # Parses self as a numeric string and creates a Money in the given currency.
  #
  # @param currency [String, Symbol, Currency] target currency
  # @return [Money]
  def to_money(currency = nil) = Mint::Money.parse(self, currency)
end

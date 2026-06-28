# frozen_string_literal: true

class String
  # Parses self as a numeric string and creates a Money in the given currency.
  #
  # @param currency [String, Symbol, Currency] target currency
  # @return [Money]
  def to_money(currency) = Mint::Money.parse(self, currency)
end

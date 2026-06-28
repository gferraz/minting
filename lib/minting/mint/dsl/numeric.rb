# frozen_string_literal: true

# Core extension: adds money-conversion helpers to Numeric.
class Numeric
  # @return [Money] self interpreted as BRL
  def reais = Mint::Money.from(self, 'BRL')

  # @return [Money] self interpreted as USD
  def dollars = Mint::Money.from(self, 'USD')

  # @return [Money] self interpreted as EUR
  def euros = Mint::Money.from(self, 'EUR')

  # @param currency [String, Symbol, Currency] target currency
  # @return [Money] self interpreted as the given currency
  def to_money(currency) = Mint::Money.from(self, currency)

  alias dollar dollars
  alias euro euros
  alias mint to_money
end

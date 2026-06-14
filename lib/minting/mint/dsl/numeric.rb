# frozen_string_literal: true

# Mint Numeric refinements
module Mint
  refine Numeric do
    # @return [Money] self interpreted as BRL
    def reais = Mint.money(self, 'BRL')

    # @return [Money] self interpreted as USD
    def dollars = Mint.money(self, 'USD')

    # @return [Money] self interpreted as EUR
    def euros = Mint.money(self, 'EUR')

    # @param currency [String, Symbol, Currency] target currency
    # @return [Money] self interpreted as the given currency
    def to_money(currency) = Mint.money(self, currency)

    alias_method :dollar, :dollars
    alias_method :euro, :euros
    alias_method :mint, :to_money
  end
end

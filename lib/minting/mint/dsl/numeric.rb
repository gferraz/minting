# frozen_string_literal: true

# Mint Numeric refinements
module Mint
  refine Numeric do
    def reais = Mint.money(self, 'BRL')

    def dollars = Mint.money(self, 'USD')

    def euros = Mint.money(self, 'EUR')

    def to_money(currency) = Mint.money(self, currency)

    alias_method :dollar, :dollars
    alias_method :euro, :euros
    alias_method :mint, :to_money
  end
end

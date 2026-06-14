# frozen_string_literal: true

# Mint String refinement
module Mint
  refine String do

    # Parses self as a numeric string and creates a Money in the given currency.
    #
    # @param currency [String, Symbol, Currency] target currency
    # @return [Money]
    def to_money(currency) = Mint.money(to_r, currency)
  end
end

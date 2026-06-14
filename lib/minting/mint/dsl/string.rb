# frozen_string_literal: true

# Mint String refinement
module Mint
  refine String do
    def to_money(currency) = Mint.money(to_r, currency)
  end
end

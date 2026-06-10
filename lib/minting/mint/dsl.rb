# frozen_string_literal: true

# Mint refinements
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

  refine String do
    def to_money(currency) = Mint.money(to_r, currency)
  end

  def self.use_top_level_constants!
    if !defined?(::Money) && !defined?(::Currency)
      require 'minting/mint/aliases'
    elsif ::Money == Mint::Money && ::Currency == Mint::Currency
      warn 'Warning: Money and Currency already defined as Mint aliases, skipping'
    else
      raise NameError, 'Cannot define top-level Money or Currency constants: already defined'
    end
  end
end

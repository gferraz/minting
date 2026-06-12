# frozen_string_literal: true

# Mint refinements
module Mint
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

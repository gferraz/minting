# frozen_string_literal: true

# Mint refinements
module Mint
  # Registers top-level ::Money and ::Currency constants as aliases for Mint's classes.
  #
  # @raise [NameError] if ::Money or ::Currency are already defined and differ
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

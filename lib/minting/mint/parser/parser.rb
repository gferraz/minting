# frozen_string_literal: true

# Mint Money parsing (delegates to +Money.parse+)
module Mint
  extend self

  # Parses a human-readable money string into a {Money} object.
  #
  # Delegates to {Money.parse}.
  #
  # @deprecated Use {Money.parse} instead. Will be removed in v2.
  # @param input [String] Amount input, optionally including a currency symbol or code
  # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
  # @return [Money, nil]
  def parse(input, currency = nil)
    warn 'Mint.parse is deprecated and will be removed in v2.0 — use Money.parse instead'
    Money.parse(input, currency)
  end

  # Like {.parse} but raises on failure.
  #
  # Delegates to {Money.parse!}.
  #
  # @deprecated Use {Money.parse!} instead. Will be removed in v2.
  # @param input [String] Amount input, optionally including a currency symbol or code
  # @param currency [String, Symbol, Currency, nil] ISO code when not present in +input+
  # @return [Money]
  # @raise [ArgumentError] when +input+ is invalid or currency cannot be determined
  def parse!(input, currency = nil)
    warn 'Mint.parse! is deprecated and will be removed in v2 — use Money.parse! instead'
    Money.parse!(input, currency)
  end
end

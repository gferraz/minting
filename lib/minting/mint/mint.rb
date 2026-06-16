# frozen_string_literal: true

# Mint currency registration and factory (public API)
module Mint
  # Unknown currency excpetion
  class UnknownCurrency < StandardError
  end

  # Creates a new {Money} instance with the given amount and currency code.
  #
  # @param amount [Numeric] the financial value
  # @param currency_code [Currency, String] Currency code
  # @return [Money] the instantiated Money object
  # @raise [ArgumentError] if the currency code is not registered
  def self.money(amount, currency_code) = Money.from(amount, currency_code)

  # @return [Hash{String => Currency}] the frozen world-currencies hash
  # @api private
  def self.world_currencies = Registry.world_currencies

  # Executes a block with a specific rounding mode applied to all money
  # construction, parsing, change, allocation, and split operations.
  #
  # Restores the previous mode (or default) when the block exits, even on
  # exception.
  #
  # @param mode [Symbol] one of: +:half_up+, +:half_down+, +:floor+,
  #   +:ceil+, +:truncate+, +:down+
  # @yield block to execute with the rounding mode active
  # @raise [ArgumentError] if +mode+ is not a recognised rounding mode
  def self.with_rounding(mode, &) = Rounding.with_mode(mode, &)
end

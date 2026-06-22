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
  # Rounding-mode support is loaded lazily on first call. Once loaded,
  # +Currency#normalize_amount+ is patched to dispatch through the
  # rounding module, adding ~10–35&ns of overhead to every money creation
  # or mutation. When rounding modes are never used (the common case),
  # the fast path incurs zero overhead.
  #
  # @param mode [Symbol] one of: +:half_up+, +:half_down+, +:floor+,
  #   +:ceil+, +:truncate+, +:down+
  # @yield block to execute with the rounding mode active
  # @raise [ArgumentError] if +mode+ is not a recognised rounding mode
  def self.with_rounding(mode, &)
    require_relative 'rounding' unless defined?(Mint::Rounding)
    Rounding.with_mode(mode, &)
  end
end

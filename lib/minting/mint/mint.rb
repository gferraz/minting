# frozen_string_literal: true

# Mint currency registration and factory (public API)
module Mint
  # Raised when a currency cannot be resolved from a code or object.
  #
  # Inherits from +ArgumentError+ so existing +rescue ArgumentError+ handlers
  # continue to work; rescue +Mint::UnknownCurrency+ for the specific case.
  class UnknownCurrency < ArgumentError
  end

  # Creates a new {Money} instance with the given amount and currency code.
  #
  # @param amount [Numeric] the financial value
  # @param currency_code [String, Currency, Money, nil] Currency code, object,
  #   Money whose currency to reuse, or +nil+. Passed through
  #   {Mint::Currency.resolve!} so all accepted types resolve to a registered
  #   currency.
  # @return [Money] the instantiated Money object
  # @raise [ArgumentError] if the amount is not a Numeric
  # @raise [Mint::UnknownCurrency] if the currency code is not registered.
  #   +Mint::UnknownCurrency+ inherits from +ArgumentError+.
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

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
  #   {Money::Currency.resolve!} so all accepted types resolve to a registered
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
  # @deprecated Use {Money.with_rounding} instead. Will be removed in v2.
  # @param mode [Symbol] one of: +:half_up+, +:half_down+, +:floor+,
  #   +:ceil+, +:truncate+, +:down+
  # @yield block to execute with the rounding mode active
  # @raise [ArgumentError] if +mode+ is not a recognised rounding mode
  def self.with_rounding(mode, &)
    warn 'Mint.with_rounding is deprecated and will be removed in v2 — use Money.with_rounding instead'
    Money.with_rounding(mode, &)
  end
end

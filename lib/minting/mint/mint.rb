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
  def self.money(amount, currency_code) = Money.create(amount, currency_code)

  # Finds a registered currency by its code, symbol,
  # or retrieves it directly if already a Currency object.
  #
  # @param currency [String, Currency] the currency identifier or object
  # @return [Currency, nil] the registered Currency instance or nil if not found
  def self.currency(currency)
    case currency
    when nil      then nil
    when Currency then currency
    when String   then CurrencyRegistry.currencies[currency]
    else raise ArgumentError, "currency must be [Currency] ot [String] (#{currency})"
    end
  end

  # Registers a new currency, raising a KeyError if already registered.
  #
  # @param code [String] the unique currency code
  # @param subunit [Integer] the decimal subunit precision, defaults to 0
  # @param symbol [String] the display symbol
  # @param priority [Integer] parser precedence priority
  # @return [Currency] the newly registered Currency instance
  # @raise [ArgumentError] if the code contains invalid characters
  # @raise [KeyError] if the currency code is already registered
  def self.register_currency(code:, subunit: 0, symbol: '', priority: 0)
    CurrencyRegistry.register(code:, subunit:, symbol:, priority:)
  end
end

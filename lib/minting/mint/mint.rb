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
    when NilClass then nil
    when Currency then currency
    when String   then CurrencyRegistry.currencies[currency]
    else          raise ArgumentError, "currency must be [Currency], [String] or nil (#{currency})"
    end
  end

  # Returns a zero {Money} in the given currency, useful as a default value
  # for discounts, totals, or placeholders.
  #
  # @param currency [String, Currency] a currency code or object
  # @return [Money] a frozen zero-Money
  # @raise [ArgumentError] if the currency is not registered
  ZERO_MUTEX = Monitor.new

  private_constant :ZERO_MUTEX

  def self.zero(currency)
    checked = Mint.currency(currency)
    raise ArgumentError, "Invalid Currency: [#{currency}]" unless checked

    ZERO_MUTEX.synchronize do
      @zeros ||= {}
      @zeros[checked] ||= Money.send(:new, 0, checked)
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

# frozen_string_literal: true

# :nodoc:
module Mint
  # Represents a specific currency unit, identified by ISO 4217 alphabetic code.
  # Currency objects are immutable and define the properties of a monetary unit
  # including its subunit precision, display symbol, and formatting rules.
  #
  # @see https://www.iso.org/iso-4217-currency-codes.html
  # @attr_reader code [String] ISO 4217 currency code (e.g., "USD", "EUR")
  # @attr_reader subunit [Integer] Number of decimal places (0 for JPY, 2 for USD, 3 for IQD)
  # @attr_reader symbol [String] Display symbol (e.g., "$", "€", "R$")
  # @attr_reader priority [Integer] Parser precedence for symbol detection
  # @attr_reader country [String, nil] Associated country code
  # @attr_reader name [String, nil] Currency name
  # @attr_reader fractional_multiplier [Integer] 10^subunit, used for fractional conversions
  # @attr_reader minimum_amount [Rational] Smallest representable amount (1/fractional_multiplier)
  # @attr_reader disambiguate_symbol [String, nil] A longer, code-prefixed variant to distinguish
  #   currencies that share the same primary symbol (e.g. "US$" for USD, "C$" for CAD).
  Currency = Data.define(:code, :subunit, :symbol, :priority, :country, :name,
                         :fractional_multiplier, :disambiguate_symbol) do
    # @param code [String] ISO 4217 currency code
    # @param symbol [String] Display symbol
    # @param subunit [Integer] Number of decimal places (default 0)
    # @param priority [Integer] Parser precedence for symbol detection (default 0)
    # @param country [String, nil] Associated country code (default nil)
    # @param name [String, nil] Currency name (default nil)
    def initialize(code:, symbol:, subunit: 0, priority: 0, country: nil, name: nil,
                   disambiguate_symbol: nil)
      subunit = subunit.to_i
      priority = priority.to_i
      fractional_multiplier = 10**subunit
      symbol = nil if symbol && symbol.empty?
      disambiguate_symbol = nil if [code, symbol].include? disambiguate_symbol
      super(code:, subunit:, symbol:, priority:, country:, name:,
            fractional_multiplier:, disambiguate_symbol:)
    end

    # @return [String] debug representation
    def inspect = "<Currency:(#{code} #{symbol} #{subunit} #{name})>"

    # @return [Rational] smallest representable amount (1/fractional_multiplier)
    def minimum_amount = Rational(1, fractional_multiplier)

    # Normalizes a numeric amount for this currency.
    #
    # @param amount [Numeric] the monetary amount to normalize
    # @return [Rational] the amount converted to +Rational+ and rounded to
    #   the currency's subunit precision (half-up by default)
    # @example
    #   usd = Money::Currency.for_code('USD')
    #   usd.normalize_amount(10.567)  #=> (10567/1000)
    #   usd.normalize_amount("5.25")  #=> (21/4)
    #
    # @see Mint::Rounding.apply Custom rounding modes via {Money.with_rounding}
    def normalize_amount(amount) = amount.to_r.round(subunit)

    # Returns the cached frozen zero-Money for this currency.
    #
    # @return [Money] a frozen zero-Money instance
    # @example
    #   Money::Currency.for_code('USD').zero  #=> [USD 0.00]
    def zero = Registry.zero_for(self)

    def dsymbol
      disambiguate_symbol || (Registry.symbol_shared?(symbol) ? code : symbol)
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
  def Currency.register(code:, subunit: 0, symbol: '', priority: 0)
    Registry.register(code:, subunit:, symbol:, priority:)
  end

  # Resolves an object into a {Currency}, returning +nil+ when it can't.
  #
  # Accepts +nil+, +String+, {Currency}, {Money}, or any object implementing
  # +#to_currency+ (must return {Currency}) or +#currency_code+ (must return +String+).
  #
  # @param object [String, Currency, Money, nil, #to_currency, #currency_code]
  #   a currency code, object, or +nil+
  # @return [Currency, nil] the resolved Currency, or +nil+ if +object+ is +nil+
  #   or the code is not registered
  # @raise [ArgumentError] if +object+ is an unsupported type, or if the method
  #   used to resolve it returns a value of the wrong type
  def Currency.resolve(object)
    case object
    when NilClass then nil
    when Currency then object
    when Money    then object.currency
    when String   then Currency.for_code object
    else
      if object.respond_to?(:to_currency)
        result = object.to_currency
        unless result.is_a?(Currency)
          raise ArgumentError, "#to_currency must return a [Money::Currency], got #{result.class}"
        end

        result
      elsif object.respond_to?(:currency_code)
        result = object.currency_code
        raise ArgumentError, "#currency_code must return a [String], got #{result.class}" unless result.is_a?(String)

        Currency.for_code result
      else
        raise ArgumentError, "currency must be [Money::Currency], [Money], [String] or nil (#{object})"
      end
    end
  end

  # Resolves an object into a {Currency}, raising on failure.
  #
  # Like {.resolve} but raises when the result would be +nil+.
  #
  # @param object [String, Currency, Money, nil] a currency code, object, or +nil+
  # @return [Currency] the resolved Currency
  # @raise [Mint::UnknownCurrency] if +object+ cannot be resolved into a
  #   registered currency. +Mint::UnknownCurrency+ inherits from +ArgumentError+,
  #   so existing +rescue ArgumentError+ handlers continue to work.
  def Currency.resolve!(object)
    resolve(object) or raise Mint::UnknownCurrency, "Could not resolve (#{object}) into a currency"
  end

  # Returns all registered currencies as a frozen hash keyed by ISO code.
  #
  # @return [Hash{String => Currency}] frozen hash of all registered currencies
  # @example Iterate over registered currencies
  #   Currency.registered_currencies.each { |code, currency| puts "#{code}: #{currency.name}" }
  # @example Count of registered currencies
  #   Currency.registered_currencies.size  #=> 154
  def Currency.registered_currencies = Registry.currencies

  # Looks up a registered currency by its alpha code.
  #
  # @param code [String] the currency code
  # @return [Currency, nil] the registered Currency, or +nil+ if not found
  def Currency.for_code(code)
    Registry.currencies[code]
  end

  # Looks up a currency by its display symbol.
  #
  # @param symbol [String] the display symbol (e.g. "$", "R$")
  # @return [Currency, nil] the highest-priority currency for the symbol
  def Currency.for_symbol(symbol)
    Registry.currency_for_symbol(symbol)
  end

  # Returns a zero {Money} in the given currency, useful as a default value
  # for discounts, totals, or placeholders.
  #
  # @param currency [String, Currency] a currency code or object
  # @return [Money] a frozen zero-Money
  # @raise [Mint::UnknownCurrency] if the currency can't be resolved
  def Currency.zero(currency) = Registry.zero_for(Currency.resolve!(currency))

  # Returns the frozen hash of all built-in ISO 4217 world currencies.
  #
  # @return [Hash{String => Currency}] ISO-4217 world currencies mapped by code
  # @api private
  def Currency.world_currencies = Registry.world_currencies

  # Returns the list of built-in crypto currency definitions.
  #
  # These are not registered by default — call {.register_crypto} to opt in.
  #
  # @return [Array<Currency>] frozen array of crypto currency definitions
  def Currency.crypto_currencies = Registry.crypto_currencies

  # Registers one or more crypto currencies into the shared currency registry.
  #
  # Raises on duplicate registration or unknown code — use +rescue+ if
  # idempotent bulk registration is needed.
  #
  # @param codes [Array<String>] one or more crypto currency codes
  # @raise [ArgumentError] if a code is not a known crypto currency
  # @raise [KeyError] if the currency code is already registered
  # @return [Array<Currency>] the newly registered Currency objects
  def Currency.register_crypto(...) = Registry.register_crypto(...)

  # Registers all built-in crypto currencies at once.
  #
  # Raises on the first duplicate — call +rescue+ if idempotency is needed.
  #
  # @raise [KeyError] if any currency code is already registered
  # @return [Array<Currency>] the newly registered Currency objects
  def Currency.register_all_crypto = Registry.register_all_crypto
end

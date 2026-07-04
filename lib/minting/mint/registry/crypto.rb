# frozen_string_literal: true

# Crypto currency definitions (opt-in registration)
module Mint
  # Internal registry for currencies, symbols, and zero-money cache.
  module Registry
    @crypto_currencies = nil
    CRYPTO_MUTEX = Monitor.new

    private_constant :CRYPTO_MUTEX

    # Returns the list of built-in crypto currency definitions.
    #
    # These are not registered by default — call {.register_crypto} to opt in.
    #
    # @return [Array<Currency>] frozen array of crypto currency definitions
    def self.crypto_currencies
      @crypto_currencies || CRYPTO_MUTEX.synchronize do
        @crypto_currencies ||= begin
          path = File.join(File.expand_path('../../data', __dir__), 'crypto-currencies.yaml')
          YAML.load_file(path).map { |entry| Currency.new(**entry.transform_keys(&:to_sym)) }.freeze
        end
      end
    end

    # Registers one or more crypto currencies into the shared currency registry.
    #
    # Raises on duplicate registration or unknown code — use +rescue+ if
    # idempotent bulk registration is needed.
    #
    # @param codes [Array<String>] one or more crypto currency codes
    # @raise [ArgumentError] if a code is not a known crypto currency
    # @raise [KeyError] if the currency code is already registered
    # @return [Array<Currency>] the newly registered Currency objects
    def self.register_crypto(*codes)
      entries = crypto_currencies
      index = entries.each_with_index.to_h { |c, i| [c.code, i] }
      missing = codes.reject { |code| index.key?(code) }
      raise ArgumentError, "Unknown crypto code(s): #{missing.join(', ')}" unless missing.empty?

      codes.map do |code|
        c = entries[index[code]]
        Currency.register(code:, subunit: c.subunit, symbol: c.symbol, priority: c.priority)
      end
    end

    # Registers all built-in crypto currencies at once.
    #
    # Raises on the first duplicate — call +rescue+ if idempotency is needed.
    #
    # @raise [KeyError] if any currency code is already registered
    # @return [Array<Currency>] the newly registered Currency objects
    def self.register_all_crypto
      crypto_currencies.map do |c|
        Currency.register(code: c.code, subunit: c.subunit, symbol: c.symbol, priority: c.priority)
      end
    end
  end
end

# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    # Registers a new currency, raising a KeyError if already registered.
    #
    # @param code [String] the unique currency code
    # @param subunit [Integer] the decimal subunit precision, defaults to 0
    # @param symbol [String] the display symbol
    # @param priority [Integer] parser precedence priority
    # @param country [String, nil] associated country code
    # @param name [String, nil] currency name
    # @param disambiguate_symbol [String, nil] symbol variant for disambiguation
    # @return [Currency] the newly registered Currency instance
    # @raise [ArgumentError] if the code contains invalid characters
    # @raise [KeyError] if the currency code is already registered
    def self.register(code:, subunit: 0, symbol: '', priority: 0, country: nil, name: nil,
                      disambiguate_symbol: nil)
      raise ArgumentError, 'Currency code must be String' unless code.is_a? String
      unless code.match?(/^[A-Z_]+$/)
        raise ArgumentError,
              "Currency code must have only letters or '_' ('USD',, 'MY_COIN')"
      end

      MUTEX.synchronize do
        raise KeyError, "Currency: #{code} already registered" if currencies[code]

        currency = Currency.new(code:, subunit:, symbol:, priority:, country:, name:, disambiguate_symbol:)
        @currencies = @currencies.merge(code => currency).freeze
        @symbols_list = nil
        currency
      end
    end
  end
end

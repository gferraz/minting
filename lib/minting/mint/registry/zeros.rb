# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    # Returns the cached zero-Money for a currency, creating it if needed.
    #
    # @param currency [Currency] the currency object
    # @return [Money] a frozen zero-Money
    # @api private
    def self.zero_for(currency)
      raise ArgumentError, "Expect a Currency param. (#{currency})" unless currency.is_a?(Currency)

      return @zeros[currency] if @zeros&.key?(currency)

      MUTEX.synchronize do
        @zeros ||= {}
        @zeros[currency] ||= Mint::Money.send(:new, 0r, currency)
      end
    end
  end
end

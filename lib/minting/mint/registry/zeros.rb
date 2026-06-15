# frozen_string_literal: true

module Mint
  # :nodoc:
  module Registry
    module_function

    # Returns the cached zero-Money for a currency, creating it if needed.
    #
    # @param currency [Currency] the currency object
    # @return [Money] a frozen zero-Money
    # @api private
    def zero_for(currency)
      MUTEX.synchronize do
        @zeros ||= {}
        @zeros[currency] ||= Mint::Money.send(:new, 0, currency)
      end
    end
  end
end

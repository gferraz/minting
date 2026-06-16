# frozen_string_literal: true

module Mint
  # Money Arithmetics
  class Money
    # Returns the absolute value of the monetary amount as a new {Money} instance.
    #
    # @return [Money] the absolute value
    def abs = change(amount.abs)

    # Returns true if the monetary amount is less than zero.
    #
    # @return [Boolean] true if negative, false otherwise
    def negative? = amount.negative?

    # Returns true if the monetary amount is greater than zero.
    #
    # @return [Boolean] true if positive, false otherwise
    def positive? = amount.positive?

    # Returns the successor of the Money instance by adding the minimum possible subunit amount.
    # Enables standard ranges and stepping (e.g. `1.dollar..10.dollars`).
    #
    # @return [Money] successor Money instance
    def succ = change(amount + currency.minimum_amount)
  end
end

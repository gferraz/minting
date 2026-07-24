# frozen_string_literal: true

# :nodoc:
module Mint
  # :nodoc:
  class Currency
    # Maps mode symbols to their +half:+ kwarg values for +Rational#round+.
    # @return [Hash{Symbol, Symbol}]
    # @api private
    ROUNDINGS = { half_up: :up, half_down: :down, half_even: :even }.freeze

    # @api private
    ROUNDING_THREAD_KEY = :minting_rounding_mode

    # @return [Boolean] whether a custom rounding mode has been activated
    # @api private
    def self.custom_rounding_active? = @custom_rounding_active

    # Activates the custom rounding dispatch path in {#normalize_amount}.
    # Once called, this cannot be reversed for the lifetime of the process.
    # @api private
    def self.activate_custom_rounding! = @custom_rounding_active = true

    # Returns the currently active rounding mode, falling back to +:half_up+.
    # @api private
    # @return [Symbol]
    def self.current_rounding_mode
      Thread.current[ROUNDING_THREAD_KEY] || :half_up
    end

    # Sets a rounding mode for the duration of a block, restoring the
    # previous mode on exit (even on exception).
    # @api private
    # @param mode [Symbol]
    # @yield block to execute with the mode active
    # @raise [ArgumentError] on unknown mode
    def self.rounding_mode(mode)
      raise ArgumentError, "Unknown rounding mode: #{mode}" unless ROUNDINGS.key?(mode)

      prev = Thread.current[ROUNDING_THREAD_KEY]
      Thread.current[ROUNDING_THREAD_KEY] = mode
      yield
    ensure
      Thread.current[ROUNDING_THREAD_KEY] = prev
    end
  end
end

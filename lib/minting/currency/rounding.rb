# frozen_string_literal: true

# :nodoc:
module Mint
  # :nodoc:
  class Currency
    # @api private
    VALID_ROUNDING_MODES = %i[up down even].freeze

    # @api private
    ROUNDING_THREAD_KEY = :minting_rounding_mode

    # @return [Boolean] whether a custom rounding mode has been activated
    # @api private
    def self.custom_rounding_active? = @custom_rounding_active

    # Activates the custom rounding dispatch path in {#normalize_amount}.
    # Once called, this cannot be reversed for the lifetime of the process.
    # @api private
    def self.activate_custom_rounding! = @custom_rounding_active = true

    # Returns the currently active rounding mode, falling back to +:up+.
    # @api private
    # @return [Symbol] one of +:up+, +:down+, +:even+
    def self.current_rounding_mode
      Thread.current[ROUNDING_THREAD_KEY] || :up
    end

    # Sets a rounding mode for the duration of a block, restoring the
    # previous mode on exit (even on exception).
    # @api private
    # @param mode [Symbol] one of +:up+, +:down+, +:even+
    # @yield block to execute with the mode active
    # @raise [ArgumentError] on unknown mode
    def self.rounding_mode(mode)
      unless VALID_ROUNDING_MODES.include?(mode)
        raise ArgumentError, "Unknown rounding mode: #{mode} (expected :up, :down, or :even)"
      end

      prev = Thread.current[ROUNDING_THREAD_KEY]
      Thread.current[ROUNDING_THREAD_KEY] = mode
      yield
    ensure
      Thread.current[ROUNDING_THREAD_KEY] = prev
    end
  end
end

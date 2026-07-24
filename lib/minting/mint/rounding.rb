# frozen_string_literal: true

module Mint
  # Rounding-mode dispatch table and block-scoped context.
  # @api private
  module Rounding
    # Maps mode symbols to their +half:+ kwarg values for +Rational#round+.
    # @return [Hash{Symbol => Symbol}]
    # @api private
    MODES = {
      half_up: :up,
      half_down: :down,
      half_even: :even
    }.freeze

    THREAD_KEY = :minting_rounding_mode

    # Returns the currently active rounding mode, falling back to +:half_up+.
    # @api private
    # @return [Symbol]
    def self.current_mode
      Thread.current[THREAD_KEY] || :half_up
    end

    # Rounds +amount+ to +ndigits+ using the currently scoped rounding mode.
    # Uses the fast path (+to_r.round+) when no custom mode is active.
    # @api private
    # @param amount [Numeric]
    # @param ndigits [Integer]
    # @return [Rational]
    def self.apply(amount, ndigits)
      mode = Thread.current[THREAD_KEY]
      if mode
        amount.to_r.round(ndigits, half: MODES.fetch(mode))
      else
        amount.to_r.round(ndigits)
      end
    end

    # Sets a rounding mode for the duration of a block, restoring the
    # previous mode on exit (even on exception).
    # @api private
    # @param mode [Symbol]
    # @yield block to execute with the mode active
    # @raise [ArgumentError] on unknown mode
    def self.with_mode(mode)
      raise ArgumentError, "Unknown rounding mode: #{mode}" unless MODES.key?(mode)

      prev = Thread.current[THREAD_KEY]
      Thread.current[THREAD_KEY] = mode
      yield
    ensure
      Thread.current[THREAD_KEY] = prev
    end
  end
end

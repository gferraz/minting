# frozen_string_literal: true

module Mint
  # Rounding-mode dispatch table and block-scoped context.
  # @api private
  module Rounding
    # Maps mode symbols to their corresponding +Rational+ rounding lambdas.
    # @return [Hash{Symbol => Proc}]
    # @api private
    MODES = {
      half_up: ->(amount, ndigits) { amount.round(ndigits, half: :up) },
      half_down: ->(amount, ndigits) { amount.round(ndigits, half: :down) },
      floor: ->(amount, ndigits) { amount.floor(ndigits) },
      ceil: ->(amount, ndigits) { amount.ceil(ndigits) },
      truncate: ->(amount, ndigits) { amount.truncate(ndigits) },
      down: ->(amount, ndigits) { amount.truncate(ndigits) }
    }.freeze

    # Returns the currently active rounding mode, falling back to +:half_up+.
    # @api private
    # @return [Symbol]
    def self.current_mode
      Thread.current[:minting_rounding_mode] || :half_up
    end

    # Rounds +amount+ to +ndigits+ using the currently scoped rounding mode.
    # @api private
    # @param amount [Numeric]
    # @param ndigits [Integer]
    # @return [Rational]
    def self.apply(amount, ndigits)
      MODES.fetch(current_mode).call(amount.to_r, ndigits)
    end

    # Sets a rounding mode for the duration of a block, restoring the
    # previous mode on exit (even on exception).
    # @api private
    # @param mode [Symbol]
    # @yield block to execute with the mode active
    # @raise [ArgumentError] on unknown mode
    def self.with_mode(mode)
      raise ArgumentError, "Unknown rounding mode: #{mode}" unless MODES.key?(mode)

      prev = Thread.current[:minting_rounding_mode]
      Thread.current[:minting_rounding_mode] = mode
      yield
    ensure
      Thread.current[:minting_rounding_mode] = prev
    end
  end
end

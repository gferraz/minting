# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    # Executes a block with a specific rounding mode applied to all money
    # construction, parsing, change, allocation, and split operations.
    #
    # Restores the previous mode (or default) when the block exits, even on
    # exception.
    #
    # Rounding-mode support is activated on first call. Before activation,
    # +Currency#normalize_amount+ uses a direct +Rational#round+ fast path with
    # no thread-local lookup. Once activated, normalization reads the
    # thread-local mode so custom rounding remains isolated per thread.
    #
    # @param mode [Symbol] one of: +:up+, +:down+, +:even+
    # @yield block to execute with the rounding mode active
    # @raise [ArgumentError] if +mode+ is not a recognised rounding mode
    def self.with_rounding(mode, &)
      Currency.activate_custom_rounding!
      Currency.rounding_mode(mode, &)
    end
  end
end

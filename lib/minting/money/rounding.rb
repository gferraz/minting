# frozen_string_literal: true

module Mint
  class Money
    # Executes a block with a specific rounding mode applied to all money
    # construction, parsing, change, allocation, and split operations.
    #
    # Restores the previous mode (or default) when the block exits, even on
    # exception.
    #
    # Rounding-mode support is loaded lazily on first call. Once loaded,
    # +Currency#normalize_amount+ is patched to dispatch through the
    # rounding module, adding ~10–35&ns of overhead to every money creation
    # or mutation. When rounding modes are never used (the common case),
    # the fast path incurs zero overhead.
    #
    # @param mode [Symbol] one of: +:half_up+, +:half_down+, +:floor+,
    #   +:ceil+, +:truncate+, +:down+
    # @yield block to execute with the rounding mode active
    # @raise [ArgumentError] if +mode+ is not a recognised rounding mode
    def self.with_rounding(mode, &)
      require_relative '../mint/rounding' unless defined?(Mint::Rounding)
      Mint::Rounding.with_mode(mode, &)
    end
  end
end

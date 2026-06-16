# frozen_string_literal: true

module Mint
  # @api private
  module Rounding
    MODES = {
      half_up: ->(amount, ndigits) { amount.round(ndigits, half: :up) },
      half_down: ->(amount, ndigits) { amount.round(ndigits, half: :down) },
      floor: ->(amount, ndigits) { amount.floor(ndigits) },
      ceil: ->(amount, ndigits) { amount.ceil(ndigits) },
      truncate: ->(amount, ndigits) { amount.truncate(ndigits) },
      down: ->(amount, ndigits) { amount.truncate(ndigits) }
    }.freeze

    module_function

    def current_mode
      Thread.current[:minting_rounding_mode] || :half_up
    end

    def apply(amount, ndigits)
      MODES.fetch(current_mode).call(amount.to_r, ndigits)
    end

    def with_mode(mode)
      mode = mode.to_sym
      raise ArgumentError, "unknown rounding mode: #{mode}" unless MODES.key?(mode)

      prev = Thread.current[:minting_rounding_mode]
      Thread.current[:minting_rounding_mode] = mode
      yield
    ensure
      Thread.current[:minting_rounding_mode] = prev
    end
  end
end

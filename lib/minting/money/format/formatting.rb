# frozen_string_literal: true

module Mint
  # :nodoc:
  class Money
    private

    # Validates that format hash contains only known keys.
    # @private
    def validate_format_hash(format)
      unknown = format.keys - %i[positive negative zero]

      raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
    end
  end
end

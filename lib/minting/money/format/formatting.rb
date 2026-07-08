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

    # Validates +decimal+ and +thousand+ separator arguments.
    # @private
    def validate_separators!(decimal:, thousand:)
      case decimal
      when nil      # :noop
      when ''       then raise ArgumentError, 'decimal must be a non-empty'
      when thousand then raise ArgumentError, "decimal and thousand cannot be identical: #{decimal.inspect}"
      when String   # :noop
      else raise ArgumentError, "decimal must be a String, false, or nil, got #{decimal.inspect}"
      end

      case thousand
      when false, nil, String # :noop
      else raise ArgumentError, "thousand must be a String, false, or nil, got #{thousand.inspect}"
      end
    end
  end
end

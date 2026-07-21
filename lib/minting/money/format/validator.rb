# frozen_string_literal: true

module Mint
  class Money
    # Shared validation for format templates and separator configuration.
    #
    # @api private
    module FormatterValidator
      def validate_format!(format)
        raise ArgumentError, 'template must not be empty' if format == {}

        unknown = format.keys - %i[positive negative zero]
        raise ArgumentError, "Unknown format parameter(s): #{unknown.inspect}. " unless unknown.empty?
      end

      def validate_separators!(decimal:, thousand:)
        case decimal
        when ''       then raise ArgumentError, "decimal separator must be a non-empty - #{decimal.inspect}"
        when /\d/     then raise ArgumentError, "decimal separator cannot be a numeral - #{decimal.inspect}"
        when thousand then raise ArgumentError, "decimal and thousand cannot be identical - #{decimal.inspect}"
        when String # :noop
        else raise ArgumentError, "decimal must be a String, false, or nil, got #{decimal.inspect}"
        end

        case thousand
        when false, nil # :noop
        when /\d/ then raise ArgumentError, "decimal separator cannot be a numeral - #{decimal.inspect}"
        when String # :noop
        else raise ArgumentError, "thousand must be a String, false, or nil, got #{thousand.inspect}"
        end
      end
    end
  end
end

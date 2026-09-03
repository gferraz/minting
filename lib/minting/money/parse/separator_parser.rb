# frozen_string_literal: true

module Mint
  class Money
    # Parses numeric input when the decimal separator is explicitly known.
    # @api private
    module SeparatorParser
      module_function

      def parse(numeric, decimal, thousand)
        decimal, thousand = separators(decimal, thousand)
        return nil unless decimal && thousand && decimal != thousand

        sign = numeric.start_with?('-', '+') ? numeric[0] : ''
        unsigned = numeric.delete_prefix(sign)
        return nil if unsigned.count(decimal) > 1

        return parse_decimal(sign, unsigned, decimal, thousand) if unsigned.include?(decimal)
        return parse_thousands(sign, unsigned, thousand) if unsigned.include?(thousand)
        return "#{sign}#{unsigned}" if unsigned.match?(/\A\d+\z/)

        nil
      end

      def separators(decimal, thousand)
        return [decimal, thousand] if decimal && thousand
        return [decimal, decimal == ',' ? '.' : ','] if %w[. ,].include?(decimal)
        return [thousand == ',' ? '.' : ',', thousand] if %w[. ,].include?(thousand)

        nil
      end
      private_class_method :separators

      def parse_decimal(sign, unsigned, decimal, thousand)
        integral, fractional = unsigned.split(decimal, 2)
        return nil unless valid_integer_part?(integral, thousand) && fractional.match?(/\A\d+\z/)

        "#{sign}#{integral.delete(thousand)}.#{fractional}"
      end
      private_class_method :parse_decimal

      def parse_thousands(sign, unsigned, thousand)
        return nil unless valid_integer_part?(unsigned, thousand)

        "#{sign}#{unsigned.delete(thousand)}"
      end
      private_class_method :parse_thousands

      def valid_integer_part?(integer, thousand)
        return integer.match?(/\A\d+\z/) unless integer.include?(thousand)

        groups = integer.split(thousand)
        groups.first.match?(/\A\d{1,3}\z/) && groups.drop(1).all? { |group| group.match?(/\A\d{3}\z/) }
      end
      private_class_method :valid_integer_part?
    end

    private_constant :SeparatorParser
  end
end

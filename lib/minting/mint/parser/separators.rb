# frozen_string_literal: true

# Mint Money parsing
module Mint
  extend self

  private

  # Classifies the separator pattern in a numeric string.
  # @private
  def classify_separators(numeric)
    case [numeric.count('.'), numeric.count(',')]
    in [0, 1] if numeric[-4] == ',' then :thousands_comma  # Comma is a thousand separator
    in [0, 1]                       then :decimal_comma    # Only one comma: decimal (e.g. 19,99 or 1,4 or 1,2345).
    in [0, 0] | [1, 0]              then :decimal_period   # e.g. "1500" or "34.21".
    in [p, c] if p > 1 && c > 1     then :ambiguous        # Both separators appear multiple times
    in [p, c] if p > 0 && c > 0     then :mixed            # Commas and dots: the rightmost one is the decimal
    else                                 :thousands        # Multiple of the same separator only (e.g. 1,234,567)
    end
  end

  # Converts locale-specific decimal/thousand separators into a plain decimal string.
  # @private
  def normalize_separators(numeric)
    case classify_separators(numeric)
    when :decimal_period   then numeric # Nothing to normalize (e.g. "1500" or "34.21").
    when :decimal_comma    then numeric.tr(',', '.') # Only one comma: decimal (e.g. 19,99 or 1,234).
    when :thousands_comma  then numeric.delete(',')
    when :thousands        then numeric.delete('.,')
    when :ambiguous then   raise ArgumentError, "could not distinguish decimal and thousand separators in '#{numeric}'"
    when :mixed # Commas and dots: the rightmost one is the decimal separator.
      if numeric.rindex(',') > numeric.rindex('.')
        numeric.delete('.').tr(',', '.')
      else
        numeric.delete(',')
      end
    end
  end
end

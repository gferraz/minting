# frozen_string_literal: true

# Mint Money parsing
module Mint
  extend self

  private

  # Classifies the separator pattern in a numeric string.
  #
  # @param numeric [String] numeric characters including commas and periods
  # @return [Symbol] one of :decimal_period, :decimal_comma, :thousands_only, :mixed, :ambiguous
  def classify_separators(numeric)
    case [numeric.count(','), numeric.count('.')]
    in [0, 0] | [0, 1]          then :decimal_period # e.g. "1500" or "34.21".
    in [1, 0]                   then :decimal_comma  # Only one comma: decimal (e.g. 19,99 or 1,234).
    in [c, p] if c > 1 && p > 1 then :ambiguous      # Both separators appear multiple times
    in [c, p] if c > 0 && p > 0 then :mixed          # Commas and dots: the rightmost one is the decimal separator.
    else                             :thousands_only # Multiple of the same separator only (e.g. 1,234,567)
    end
  end

  # Converts locale-specific decimal/thousand separators into a plain decimal string.
  def normalize_separators(numeric)
    case classify_separators(numeric)
    when :decimal_period then numeric              # Nothing to normalize (e.g. "1500" or "34.21").
    when :decimal_comma  then numeric.tr(',', '.') # Only one comma: decimal (e.g. 19,99 or 1,234).
    when :thousands_only then numeric.delete(',.')
    when :ambiguous then raise ArgumentError, "could not distinguish decimal and thousand separators in '#{numeric}'"
    when :mixed # Commas and dots: the rightmost one is the decimal separator.
      if numeric.rindex(',') > numeric.rindex('.')
        numeric.delete('.').tr(',', '.')
      else
        numeric.delete(',')
      end
    end
  end
end

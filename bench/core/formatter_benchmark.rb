# frozen_string_literal: true

require_relative '../benchmark_helper'
require_relative '../../lib/minting/money/format/formatter2'

class FormatterBenchmark < Minitest::Test
  include BenchmarkHelper

  F1 = Mint::Money::Formatter
  F2 = Mint::Money::Formatter2

  TEMPLATES = {
    simple: { positive: '%<symbol>s%<amount>f' },
    full: { positive: '%<symbol>s%<amount>f (%<currency>s)' },
    accounting: { negative: '(%<symbol>s%<amount>f)', zero: '%<symbol>s -', positive: '%<symbol>s%<amount>f' },
    integral_frac: { positive: '%<integral>d.%<fractional>02d' }
  }.freeze

  DECIMAL_COMMA = { positive: '%<symbol>s%<amount>f' }

  def setup
    @usd = Money.from(1234.56, 'USD')
    @usd_small = Money.from(9.99, 'USD')
    @usd_large = Money.from(1_000_000.42, 'USD')
    @usd_zero = Money.from(0, 'USD')
    @jpy = Money.from(123_456, 'JPY')
  end

  def test_formatter_comparison_simple
    with_bench('Simple Format (%<symbol>s%<amount>f)') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      f2 = F2.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd) }
        x.report('Formatter2 (preformat)') { f2.format(@usd) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_full
    with_bench('Full Format (%<symbol>s%<amount>f (%<currency>s))') do
      f1 = F1.for(TEMPLATES[:full], '.', ',')
      f2 = F2.for(TEMPLATES[:full], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd) }
        x.report('Formatter2 (preformat)') { f2.format(@usd) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_accounting
    with_bench('Accounting Format (negative hash)') do
      f1 = F1.for(TEMPLATES[:accounting], '.', ',')
      f2 = F2.for(TEMPLATES[:accounting], '.', ',')
      neg = -@usd
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(neg) }
        x.report('Formatter2 (preformat)') { f2.format(neg) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_integral_frac
    with_bench('Integral+Fractional Format') do
      f1 = F1.for(TEMPLATES[:integral_frac], '.', ',')
      f2 = F2.for(TEMPLATES[:integral_frac], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd) }
        x.report('Formatter2 (preformat)') { f2.format(@usd) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_comma_decimal
    with_bench('Comma Decimal (%<symbol>s%<amount>f with , decimal)') do
      f1 = F1.for(DECIMAL_COMMA, ',', '.')
      f2 = F2.for(DECIMAL_COMMA, ',', '.')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd) }
        x.report('Formatter2 (preformat)') { f2.format(@usd) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_large_amount
    with_bench('Large Amount with Thousand Separators') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      f2 = F2.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd_large) }
        x.report('Formatter2 (preformat)') { f2.format(@usd_large) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_zero
    with_bench('Zero Amount') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      f2 = F2.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@usd_zero) }
        x.report('Formatter2 (preformat)') { f2.format(@usd_zero) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_jpy
    with_bench('JPY (0 subunit)') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      f2 = F2.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (original)') { f1.format(@jpy) }
        x.report('Formatter2 (preformat)') { f2.format(@jpy) }
        x.compare!
      end
    end
  end

  def test_formatter_comparison_cached_hit
    with_bench('Cached Formatter (hot path)') do
      F1.for(TEMPLATES[:simple], '.', ',')
      F2.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter  (cached)') { F1.for(TEMPLATES[:simple], '.', ',').format(@usd) }
        x.report('Formatter2 (cached)') { F2.for(TEMPLATES[:simple], '.', ',').format(@usd) }
        x.compare!
      end
    end
  end
end

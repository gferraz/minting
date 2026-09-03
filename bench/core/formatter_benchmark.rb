# frozen_string_literal: true

require_relative '../benchmark_helper'

class FormatterBenchmark < Minitest::Test
  include BenchmarkHelper

  F1 = Mint::Money::Formatter

  TEMPLATES = {
    simple: { positive: '%<symbol>s%<amount>f' },
    full: { positive: '%<symbol>s%<amount>f (%<currency>s)' },
    accounting: { negative: '(%<symbol>s%<amount>f)', zero: '%<symbol>s -', positive: '%<symbol>s%<amount>f' },
    integral_frac: { positive: '%<integral>d.%<fractional>02d' }
  }.freeze

  DECIMAL_COMMA = { positive: '%<symbol>s%<amount>f' }.freeze

  def setup
    @usd = Money.from(1234.56, 'USD')
    @usd_small = Money.from(9.99, 'USD')
    @usd_large = Money.from(1_000_000.42, 'USD')
    @usd_zero = Money.from(0, 'USD')
    @jpy = Money.from(123_456, 'JPY')
  end

  def test_formatter_simple
    with_bench('Simple Format (%<symbol>s%<amount>f)') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd) }
      end
    end
  end

  def test_formatter_full
    with_bench('Full Format (%<symbol>s%<amount>f (%<currency>s))') do
      f1 = F1.for(TEMPLATES[:full], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd) }
      end
    end
  end

  def test_formatter_accounting
    with_bench('Accounting Format (negative hash)') do
      f1 = F1.for(TEMPLATES[:accounting], '.', ',')
      neg = -@usd
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(neg) }
      end
    end
  end

  def test_formatter_integral_frac
    with_bench('Integral+Fractional Format') do
      f1 = F1.for(TEMPLATES[:integral_frac], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd) }
      end
    end
  end

  def test_formatter_comma_decimal
    with_bench('Comma Decimal (%<symbol>s%<amount>f with , decimal)') do
      f1 = F1.for(DECIMAL_COMMA, ',', '.')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd) }
      end
    end
  end

  def test_formatter_large_amount
    with_bench('Large Amount with Thousand Separators') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd_large) }
      end
    end
  end

  def test_formatter_zero
    with_bench('Zero Amount') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@usd_zero) }
      end
    end
  end

  def test_formatter_jpy
    with_bench('JPY (0 subunit)') do
      f1 = F1.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter') { f1.format(@jpy) }
      end
    end
  end

  def test_formatter_cached_hit
    with_bench('Cached Formatter (hot path)') do
      F1.for(TEMPLATES[:simple], '.', ',')
      Benchmark.ips do |x|
        x.report('Formatter (cached)') { F1.for(TEMPLATES[:simple], '.', ',').format(@usd) }
      end
    end
  end
end

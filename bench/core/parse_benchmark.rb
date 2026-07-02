# frozen_string_literal: true

require_relative '../benchmark_helper'

class ParseBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    @samples = [
      '19.99',
      '1,234.56',
      '$19.99',
      'USD 1,234.56',
      '19,99 €',
      'HK$1,234.56',
      'JPY 1000',
      '1.234,56',
      '€1.234,56',
      '1,234,567.89'
    ]

    @random = Array.new(1000) do
      amt = format('%.2f', rand(-10_000.0..10_000.0))
      case rand(4)
      when 0 then "$#{amt}"
      when 1 then "USD #{amt}"
      when 2 then "#{amt} €"
      else "#{amt} XXX"
      end
    end
  end

  def test_parse_performance
    with_bench('Money.parse performance') do
      Benchmark.ips do |x|
        x.report('Mint parse plain numeric') { Mint.parse(@samples[0], 'USD') }
        x.report('Mint parse with symbol') { Mint.parse(@samples[2]) }
        x.report('Mint parse with code') { Mint.parse(@samples[3]) }
        x.report('Mint parse european') { Mint.parse(@samples[4]) }
        x.report('Mint parse random sample') { Mint.parse(@random.sample) }
        x.compare!
      end
    end
  end

  def test_parse_allocations
    with_bench('Money.parse allocations') do
      result = measure_allocations('parse random 1000') do
        1000.times { Mint.parse(@random.sample) }
      end
      puts result.inspect
    end
  end
end

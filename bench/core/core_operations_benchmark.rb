# frozen_string_literal: true

require_relative '../benchmark_helper'

class CoreOperationsBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    @amounts = Array.new(1000) { rand(-10_000.00..10_000.00) }
    @currencies = %w[USD EUR GBP JPY BRL]
  end

  def test_money_creation_performance
    with_bench('Money Creation Performance') do
      Benchmark.ips do |x|
        x.report('Money.from(float, string)') { Money.from(123.45, 'USD') }
        x.report('Money.from(integer, string)') { Money.from(123, 'USD') }
        x.report('Money.from(rational, string)') { Money.from(123.45r, 'USD') }
        x.report('Money.from(random, random_currency)') do
          Money.from(@amounts.sample, @currencies.sample)
        end
        x.compare!
      end
    end
  end

  def test_arithmetic_operations_performance
    with_bench('Arithmetic Operations Performance') do
      m1 = Money.from(100.50, 'USD')
      m2 = Money.from(50.25, 'USD')

      Benchmark.ips do |x|
        x.report('addition') { m1 + m2 }
        x.report('subtraction') { m1 - m2 }
        x.report('multiplication') { m1 * 3.5 }
        x.report('division') { m1 / 2.5 }
        x.report('negation') { -m1 }
        x.report('absolute') { (-m1).abs }
        x.report('chain operations') { ((m1 + m2) * 2) - (m1 / 3).abs }
        x.compare!
      end
    end
  end

  def test_comparison_performance
    with_bench('Comparison Operations Performance') do
      m1 = Money.from(100.00, 'USD')
      m2 = Money.from(100.00, 'USD')
      m3 = Money.from(50.00, 'USD')

      Benchmark.ips do |x|
        x.report('equality (same)') { m1 == m2 }
        x.report('equality (different)') { m1 == m3 }
        x.report('comparison (<=>)') { m1 <=> m3 }
        x.report('greater than') { m1 > m3 }
        x.report('hash generation') { m1.hash }
        x.report('eql? check') { m1.eql?(m2) }
        x.compare!
      end
    end
  end

  def test_currency_operations_performance
    with_bench('Currency Operations Performance') do
      Benchmark.ips do |x|
        x.report('currency lookup (string)') { Currency.for_code('USD') }
        x.report('currency lookup (symbol)') { Currency.for_symbol('R$') }
        x.report('money with currency lookup') { Money.from(100, 'USD') }
        x.report('currency registration') do
          Currency.register(code: 'TEST', subunit: 2, symbol: 'T')
        end
        x.compare!
      end
    end
  end
end

require 'test_helper'
require 'benchmark/ips'

class CoreOperationsBenchmark < Minitest::Test
  def setup
    @amounts = Array.new(1000) { rand(-10_000.00..10_000.00) }
    @currencies = %w[USD EUR GBP JPY BRL]
    @money_objects = @amounts.map { |amt| Mint.money(amt, @currencies.sample) }
  end

  def test_money_creation_performance
    skip unless ENV['BENCH']

    puts "\n=== Money Creation Performance ==="

    Benchmark.ips do |x|
      x.report('Mint.money(float, string)') { Mint.money(123.45, 'USD') }
      x.report('Mint.money(integer, string)') { Mint.money(123, 'USD') }
      x.report('Mint.money(rational, string)') { Mint.money(123.45r, 'USD') }
      x.report('Mint.money(random, random_currency)') do
        Mint.money(@amounts.sample, @currencies.sample)
      end
      x.compare!
    end
  end

  def test_arithmetic_operations_performance
    skip unless ENV['BENCH']

    puts "\n=== Arithmetic Operations Performance ==="

    m1 = Mint.money(100.50, 'USD')
    m2 = Mint.money(50.25, 'USD')

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

  def test_comparison_performance
    skip unless ENV['BENCH']

    puts "\n=== Comparison Operations Performance ==="

    m1 = Mint.money(100.00, 'USD')
    m2 = Mint.money(100.00, 'USD')
    m3 = Mint.money(50.00, 'USD')

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

  def test_currency_operations_performance
    skip unless ENV['BENCH']

    puts "\n=== Currency Operations Performance ==="

    Benchmark.ips do |x|
      x.report('currency lookup (string)') { Mint.currency('USD') }
      x.report('currency lookup (symbol)') { Mint.currency(:USD) }
      x.report('currency registration') { Mint.register_currency('TEST', subunit: 2, symbol: 'T') }
      x.report('money with currency lookup') { Mint.money(100, 'USD') }
      x.compare!
    end
  end
end

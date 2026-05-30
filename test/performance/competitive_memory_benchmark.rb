require_relative 'benchmark_helper'

class CompetitiveMemoryBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    configure_money_gem
    @random_amounts = random_amounts
  end

  def test_memory_usage_comparison
    skip unless ENV['BENCH']

    puts "\n=== Memory Usage: Minting vs Money Gem ==="

    iterations = 10_000

    # Measure object creation memory usage
    measure_memory_usage("Object Creation - #{iterations} objects") do |library|
      case library
      when :mint
        iterations.times { |i| Mint.money(@random_amounts[i % @random_amounts.size], 'USD') }
      when :money
        iterations.times { |i| Money.from_amount(@random_amounts[i % @random_amounts.size], 'USD') }
      end
    end

    # Measure arithmetic operations memory usage
    measure_memory_usage("Arithmetic Operations - #{iterations} operations") do |library|
      case library
      when :mint
        money1 = Mint.money(100, 'USD')
        money2 = Mint.money(50, 'USD')
        iterations.times { ((money1 + money2) * 2) - (money1 / 3) }
      when :money
        money1 = Money.from_amount(100, 'USD')
        money2 = Money.from_amount(50, 'USD')
        iterations.times { ((money1 + money2) * 2) - (money1 / 3) }
      end
    end
  end
end

require 'test_helper'
require 'benchmark'
require 'money'
require 'bigdecimal'

using Mint

class CompetitiveMemoryBenchmark < Minitest::Test
  def setup
    Money.rounding_mode = BigDecimal::ROUND_HALF_UP
    Money.default_currency = Money::Currency.new('USD')
    @random_amounts = Array.new(1000) { rand(-1000.00..1000.00) }
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

  private

  def measure_memory_usage(description)
    puts "\n--- #{description} ---"

    # Measure Mint
    GC.start
    before_mint = ObjectSpace.count_objects.dup
    yield(:mint)
    GC.start
    after_mint = ObjectSpace.count_objects.dup

    # Measure Money gem
    GC.start
    before_money = ObjectSpace.count_objects.dup
    yield(:money)
    GC.start
    after_money = ObjectSpace.count_objects.dup

    # Calculate differences
    mint_diff = after_mint.merge(before_mint) do |_key, after_val, before_val|
      after_val - before_val
    end
    money_diff = after_money.merge(before_money) do |_key, after_val, before_val|
      after_val - before_val
    end

    # Show significant allocations
    significant_types = (mint_diff.keys + money_diff.keys).uniq.select do |k|
      (mint_diff[k] || 0) > 10 || (money_diff[k] || 0) > 10
    end

    significant_types.each do |type|
      mint_alloc = mint_diff[type] || 0
      money_alloc = money_diff[type] || 0
      puts "  #{type}:"
      puts "    Mint: #{mint_alloc}"
      puts "    Money: #{money_alloc}"
      puts "    Ratio: #{money_alloc.zero? ? 'N/A' : (mint_alloc.to_f / money_alloc).round(2)}x"
    end
  end
end

require 'test_helper'
require 'benchmark/ips'
require 'money'
require 'bigdecimal'

class CompetitiveBenchmark < Minitest::Test
  def setup
    # Configure Money gem for fair comparison
    Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
    Money.default_currency = Money::Currency.new('USD')

    @test_amounts = [1.00, 10.50, 123.45, 999.99, 1234.56]
    @random_amounts = Array.new(1000) { rand(-1000.00..1000.00) }
  end

  def test_object_creation_comparison
    skip unless ENV['BENCH']

    puts "\n=== Object Creation: Minting vs Money Gem ==="

    @test_amounts.each do |amount|
      puts "\nAmount: #{amount}"

      Benchmark.ips do |x|
        x.report('Mint.money') { Mint.money(amount, 'USD') }
        x.report('Money.new') { Money.new((amount * 100).to_i, 'USD') }
        x.report('Money.from_amount') { Money.from_amount(amount, 'USD') }
        x.compare!
      end
    end
  end

  def test_arithmetic_operations_comparison
    skip unless ENV['BENCH']

    puts "\n=== Arithmetic Operations: Minting vs Money Gem ==="

    mint_money_1 = Mint.money(100.50, 'USD')
    mint_money_2 = Mint.money(50.25, 'USD')

    gem_money_1 = Money.from_amount(100.50, 'USD')
    gem_money_2 = Money.from_amount(50.25, 'USD')

    operations = {
      'addition' => proc { |m1, m2| m1 + m2 },
      'subtraction' => proc { |m1, m2| m1 - m2 },
      'multiplication' => proc { |m1, _m2| m1 * 3.5 },
      'division' => proc { |m1, _m2| m1 / 2.5 },
      'negation' => proc { |m1, _m2| -m1 },
      'absolute' => proc { |m1, _m2| (-m1).abs }
    }

    operations.each do |op_name, operation|
      puts "\n--- #{op_name.capitalize} ---"

      Benchmark.ips do |x|
        x.report("Mint #{op_name}") { operation.call(mint_money_1, mint_money_2) }
        x.report("Money #{op_name}") { operation.call(gem_money_1, gem_money_2) }
        x.compare!
      end
    end
  end

  def test_comparison_operations_comparison
    skip unless ENV['BENCH']

    puts "\n=== Comparison Operations: Minting vs Money Gem ==="

    mint_money_1 = Mint.money(100.00, 'USD')
    mint_money_2 = Mint.money(100.00, 'USD')
    mint_money_3 = Mint.money(50.00, 'USD')

    gem_money_1 = Money.from_amount(100.00, 'USD')
    gem_money_2 = Money.from_amount(100.00, 'USD')
    gem_money_3 = Money.from_amount(50.00, 'USD')

    comparisons = {
      'equality_same' => proc { |m1, m2, _m3| m1 == m2 },
      'equality_different' => proc { |m1, _m2, m3| m1 == m3 },
      'spaceship' => proc { |m1, _m2, m3| m1 <=> m3 },
      'greater_than' => proc { |m1, _m2, m3| m1 > m3 },
      'hash_generation' => proc { |m1, _m2, _m3| m1.hash }
    }

    comparisons.each do |comp_name, comparison|
      puts "\n--- #{comp_name.humanize} ---"

      Benchmark.ips do |x|
        x.report("Mint #{comp_name}") { comparison.call(mint_money_1, mint_money_2, mint_money_3) }
        x.report("Money #{comp_name}") { comparison.call(gem_money_1, gem_money_2, gem_money_3) }
        x.compare!
      end
    end
  end

  def test_formatting_comparison
    skip unless ENV['BENCH']

    puts "\n=== String Formatting: Minting vs Money Gem ==="

    @test_amounts.each do |amount|
      mint_money = Mint.money(amount, 'USD')
      gem_money = Money.from_amount(amount, 'USD')

      puts "\nAmount: #{amount}"

      Benchmark.ips do |x|
        x.report('Mint to_s') { mint_money.to_s }
        x.report('Money to_s') { gem_money.to_s }
        x.report('Mint inspect') { mint_money.inspect }
        x.report('Money inspect') { gem_money.inspect }
        x.report('Mint to_json') { mint_money.to_json }
        x.report('Money to_json') { gem_money.to_json }
        x.compare!
      end
    end
  end

  def test_allocation_comparison
    skip unless ENV['BENCH']

    puts "\n=== Allocation Algorithms: Minting vs Money Gem ==="

    test_scenarios = [
      { amount: 10.00, desc: 'small_amount' },
      { amount: 100.00, desc: 'medium_amount' },
      { amount: 1000.00, desc: 'large_amount' }
    ]

    allocation_patterns = [
      [1, 2, 3],
      [1, 1, 1, 1, 1],
      [0.25, 0.25, 0.25, 0.25],
      (1..10).to_a
    ]

    test_scenarios.each do |scenario|
      puts "\n--- #{scenario[:desc].humanize} (#{scenario[:amount]}) ---"

      mint_money = Mint.money(scenario[:amount], 'USD')
      gem_money = Money.from_amount(scenario[:amount], 'USD')

      allocation_patterns.each_with_index do |pattern, idx|
        puts "\nPattern #{idx + 1}: #{pattern.first(3)}#{'...' if pattern.size > 3}"

        Benchmark.ips do |x|
          x.report('Mint allocate') { mint_money.allocate(pattern) }
          x.report('Money allocate') { gem_money.allocate(pattern) }

          if pattern.all? { |p| p.is_a?(Integer) || p == p.to_i }
            splits = pattern.sum
            x.report('Mint split') { mint_money.split(splits) } if mint_money.respond_to?(:split)
            x.report('Money split') { gem_money.split(splits) } if gem_money.respond_to?(:split)
          end

          x.compare!
        end
      end
    end
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

  def test_precision_accuracy_comparison
    skip unless ENV['BENCH']

    puts "\n=== Precision and Accuracy Comparison ==="

    # Test floating point edge cases
    edge_amounts = [
      0.1 + 0.2,           # Classic floating point issue
      1.0 / 3.0,           # Repeating decimal
      0.29999999999999999, # Near 0.3 boundary
      999.995,             # Rounding boundary
      0.125 # Exact binary fraction
    ]

    edge_amounts.each do |amount|
      puts "\nTesting amount: #{amount}"

      mint_money = Mint.money(amount, 'USD')
      gem_money = Money.from_amount(amount, 'USD')

      puts "  Mint internal: #{mint_money.amount} (#{mint_money.amount.class})"
      puts "  Money internal: #{gem_money.fractional} cents (#{gem_money.fractional.class})"
      puts "  Mint display: #{mint_money}"
      puts "  Money display: #{gem_money}"

      # Test arithmetic precision
      result_mint = (mint_money * 3) / 3
      result_money = (gem_money * 3) / 3

      puts "  (amount * 3) / 3 - Mint: #{result_mint}"
      puts "  (amount * 3) / 3 - Money: #{result_money}"
      puts "  Precision maintained - Mint: #{result_mint == mint_money}"
      puts "  Precision maintained - Money: #{result_money == gem_money}"
    end
  end

  def test_high_volume_transactions
    skip unless ENV['BENCH']

    puts "\n=== High Volume Transaction Simulation ==="

    # Simulate processing many transactions
    transaction_count = 50_000
    amounts = Array.new(transaction_count) { rand(1.00..1000.00) }

    puts "\nProcessing #{transaction_count} transactions..."

    # Minting performance
    mint_time = Benchmark.realtime do
      running_total = Mint.money(0, 'USD')
      amounts.each do |amount|
        transaction = Mint.money(amount, 'USD')
        running_total += transaction
        # Simulate fee calculation
        fee = transaction * 0.029 # 2.9% fee
        transaction - fee
      end
    end

    # Money gem performance
    money_time = Benchmark.realtime do
      running_total = Money.from_amount(0, 'USD')
      amounts.each do |amount|
        transaction = Money.from_amount(amount, 'USD')
        running_total += transaction
        # Simulate fee calculation
        fee = transaction * 0.029 # 2.9% fee
        transaction - fee
      end
    end

    puts "  Mint time: #{(mint_time * 1000).round(2)}ms"
    puts "  Money time: #{(money_time * 1000).round(2)}ms"
    puts "  Mint ops/sec: #{(transaction_count / mint_time).round(0)}"
    puts "  Money ops/sec: #{(transaction_count / money_time).round(0)}"
    puts "  Performance ratio: #{(money_time / mint_time).round(2)}x"
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

# Helper method for string formatting
class String
  def humanize
    tr('_', ' ').split.map(&:capitalize).join(' ')
  end
end

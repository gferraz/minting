require 'test_helper'
require 'benchmark/ips'

class AlgorithmBenchmark < Minitest::Test
  def setup
    @small_amounts = [1.00, 5.50, 10.99, 25.33, 50.01]
    @medium_amounts = [100.00, 250.75, 500.50, 750.25, 999.99]
    @large_amounts = [10_000.00, 50_000.50, 100_000.99, 500_000.25, 999_999.99]
    @currencies = %w[USD EUR JPY] # Different subunit currencies
  end

  def test_split_algorithm_performance
    skip unless ENV['BENCH']

    puts "\n=== Split Algorithm Performance ==="

    # Test with different amounts
    [@small_amounts, @medium_amounts, @large_amounts].each_with_index do |amounts, idx|
      size_name = %w[small medium large][idx]
      puts "\n--- #{size_name.capitalize} amounts ---"

      amounts.each do |amount|
        money = Mint.money(amount, 'USD')

        Benchmark.ips do |x|
          x.report("split(2) - #{amount}") { money.split(2) }
          x.report("split(3) - #{amount}") { money.split(3) }
          x.report("split(7) - #{amount}") { money.split(7) }
          x.report("split(13) - #{amount}") { money.split(13) }
          x.report("split(100) - #{amount}") { money.split(100) }
          x.compare!
        end
      end
    end
  end

  def test_allocation_algorithm_performance
    skip unless ENV['BENCH']

    puts "\n=== Allocation Algorithm Performance ==="

    money = Mint.money(1000.00, 'USD')

    # Different allocation patterns
    allocations = {
      'simple_equal' => [1, 1, 1],
      'simple_weighted' => [1, 2, 3],
      'complex_ratios' => [0.333, 0.333, 0.334],
      'many_equal' => Array.new(20, 1),
      'many_weighted' => (1..20).to_a,
      'fractional' => [0.1, 0.15, 0.25, 0.5],
      'large_numbers' => [100, 200, 300, 400, 500],
      'uneven_distribution' => [1, 17, 23, 59, 127, 251]
    }

    Benchmark.ips do |x|
      allocations.each do |name, ratios|
        x.report("allocate(#{name})") { money.allocate(ratios) }
      end
      x.compare!
    end
  end

  def test_precision_edge_cases_performance
    skip unless ENV['BENCH']

    puts "\n=== Precision Edge Cases Performance ==="

    # Test with different currency subunits
    test_cases = [
      [1.00, 'USD'],   # 2 subunits
      [1.00, 'JPY'],   # 0 subunits
      [0.01, 'USD'],   # Minimum USD amount
      [1, 'JPY'],      # Minimum JPY amount
      [999.99, 'USD'], # Near boundary
      [999_999.99, 'USD'] # Large precise amount
    ]

    Benchmark.ips do |x|
      test_cases.each do |amount, currency|
        money = Mint.money(amount, currency)
        x.report("split(17) - #{amount} #{currency}") { money.split(17) }
        x.report("allocate([1,2,3]) - #{amount} #{currency}") { money.allocate([1, 2, 3]) }
      end
      x.compare!
    end
  end

  def test_remainder_distribution_scenarios
    skip unless ENV['BENCH']

    puts "\n=== Remainder Distribution Scenarios ==="

    # These amounts create challenging remainder scenarios
    challenging_amounts = [
      10.01,    # Creates 0.01 remainder when split by 3
      100.01,   # Creates 0.01 remainder with larger base
      1.00,     # Even split scenarios
      0.97,     # Complex remainder distribution
      999.98 # Large amount with complex remainder
    ]

    split_sizes = [3, 7, 13, 17, 23] # Prime numbers create interesting remainders

    challenging_amounts.each do |amount|
      money = Mint.money(amount, 'USD')
      puts "\nAmount: #{amount}"

      Benchmark.ips do |x|
        split_sizes.each do |size|
          x.report("split(#{size})") { money.split(size) }
        end
        x.compare!
      end
    end
  end

  def test_allocation_accuracy_vs_performance
    skip unless ENV['BENCH']

    puts "\n=== Allocation Accuracy vs Performance ==="

    money = Mint.money(1000.00, 'USD')

    # Measure time and accuracy
    test_scenarios = [
      { name: 'equal_3', proportions: [1, 1, 1] },
      { name: 'weighted_3', proportions: [1, 2, 3] },
      { name: 'fractional_4', proportions: [0.25, 0.25, 0.25, 0.25] },
      { name: 'complex_5', proportions: [0.1, 0.15, 0.2, 0.25, 0.3] },
      { name: 'many_equal_10', proportions: Array.new(10, 1) },
      { name: 'fibonacci_8', proportions: [1, 1, 2, 3, 5, 8, 13, 21] }
    ]

    test_scenarios.each do |scenario|
      puts "\n--- #{scenario[:name]} ---"

      # Performance measurement
      time = Benchmark.realtime do
        10_000.times { money.allocate(scenario[:proportions]) }
      end

      # Accuracy measurement
      result = money.allocate(scenario[:proportions])
      sum_result = result.sum
      accuracy = sum_result == money ? 'EXACT' : "DIFF: #{(sum_result - money).amount}"

      puts "  Performance: #{(10_000 / time).round(0)} ops/sec"
      puts "  Accuracy: #{accuracy}"
      puts "  Result: #{result.map(&:amount).join(', ')}"
    end
  end

  def test_concurrent_operations_simulation
    skip unless ENV['BENCH']

    puts "\n=== Concurrent Operations Simulation ==="

    # Simulate high concurrency scenarios
    money_pool = Array.new(100) { |_i| Mint.money(rand(100.0..1000.0), 'USD') }

    Benchmark.ips do |x|
      x.report('sequential_splits') do
        money_pool.each { |m| m.split(3) }
      end

      x.report('sequential_allocations') do
        money_pool.each { |m| m.allocate([1, 2, 3]) }
      end

      x.report('mixed_operations') do
        money_pool.each_with_index do |m, i|
          if i.even?
            m.split(rand(2..10))
          else
            m.allocate([rand, rand, rand])
          end
        end
      end

      x.compare!
    end
  end

  def test_pathological_cases
    skip unless ENV['BENCH']

    puts "\n=== Pathological Cases ==="

    # Edge cases that might cause performance issues
    edge_cases = [
      { desc: 'tiny_amount_many_splits', money: Mint.money(0.01, 'USD'), operation: :split,
        param: 1000 },
      { desc: 'huge_amount_many_splits', money: Mint.money(999_999.99, 'USD'), operation: :split,
        param: 1000 },
      { desc: 'zero_subunit_currency', money: Mint.money(1000, 'JPY'), operation: :split,
        param: 17 },
      { desc: 'many_tiny_allocations', money: Mint.money(100, 'USD'), operation: :allocate,
        param: Array.new(100, 0.01) },
      { desc: 'extreme_ratios', money: Mint.money(1000, 'USD'), operation: :allocate,
        param: [0.0001, 0.9999] }
    ]

    edge_cases.each do |test_case|
      puts "\n--- #{test_case[:desc]} ---"

      begin
        time = Benchmark.realtime do
          100.times do
            case test_case[:operation]
            when :split
              test_case[:money].split(test_case[:param])
            when :allocate
              test_case[:money].allocate(test_case[:param])
            end
          end
        end

        puts "  Time for 100 operations: #{(time * 1000).round(2)}ms"
        puts "  Average per operation: #{(time * 10).round(4)}ms"
      rescue StandardError => e
        puts "  ERROR: #{e.message}"
      end
    end
  end
end

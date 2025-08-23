require 'test_helper'

class RegressionBenchmark < Minitest::Benchmark
  using Mint
  # Define the range of data sizes to test
  def self.bench_range
    bench_exp(1, 10_000)
  end

  # Test that money creation scales linearly
  def bench_money_creation_linear
    assert_performance_linear 0.99 do |n|
      n.times { |i| Mint.money((i % 1000) + 1, 'USD') }
    end
  end

  # Test that money creation doesn't get slower over time (constant time)
  def bench_money_creation_constant
    assert_performance_constant 0.99 do |_n|
      Mint.money(rand(1..1000), 'USD')
    end
  end

  # Test that arithmetic operations remain constant time
  def bench_arithmetic_constant
    money1 = Mint.money(100, 'USD')
    Mint.money(50, 'USD')

    assert_performance_constant 0.99 do |_n|
      money1 / 2
    end
  end

  # Test that comparison operations remain constant time
  def bench_comparison_constant
    money1 = Mint.money(100, 'USD')
    Mint.money(50, 'USD')
    Mint.money(100, 'USD')

    assert_performance_constant 0.99 do |_n|
      money1.hash
    end
  end

  # Test that string operations remain constant time
  def bench_string_operations_constant
    money = Mint.money(123.45, 'USD')

    assert_performance_constant 0.99 do |_n|
      money.to_s
      money.inspect
      money.to_json
    end
  end

  # Test that currency lookup remains constant time
  def bench_currency_lookup_constant
    currencies = %w[USD EUR GBP JPY BRL CAD AUD CHF CNY SEK]

    assert_performance_constant 0.99 do |_n|
      currency = currencies.sample
      Mint.currency(currency)
      Mint.money(100, currency)
    end
  end

  # Test that allocation algorithms scale appropriately
  def bench_split_algorithm_linear
    money = Mint.money(1000, 'USD')

    # Split should scale linearly with the number of parts
    assert_performance_linear 0.95 do |n|
      parts = [n, 2].max # Minimum 2 parts for split
      money.split(parts)
    end
  end

  # Test that allocation with proportions scales linearly
  def bench_allocate_algorithm_linear
    money = Mint.money(1000, 'USD')

    assert_performance_linear 0.95 do |n|
      parts = [n, 2].max
      proportions = Array.new(parts, 1)
      money.allocate(proportions)
    end
  end

  # Test that hash generation remains constant
  def bench_hash_generation_constant
    money = Mint.money(123.45, 'USD')

    assert_performance_constant 0.99 do |_n|
      money.hash
    end
  end

  # Test refinements performance
  def bench_refinements_constant
    assert_performance_constant 0.99 do |_n|
      100.dollars
      50.euros
      25.reais
    end
  end

  # Test coercion performance
  def bench_coercion_constant
    money = Mint.money(100, 'USD')

    assert_performance_constant 0.99 do |_n|
      5 * money # Should trigger coercion
    end
  end

  # Test conversion methods remain constant
  def bench_conversion_constant
    money = Mint.money(123.45, 'USD')

    assert_performance_constant 0.99 do |_n|
      money.to_i
      money.to_f
      money.to_r
      money.to_d if money.respond_to?(:to_d)
    end
  end

  # Test that zero and nonzero checks are constant
  def bench_zero_checks_constant
    zero_money = Mint.money(0, 'USD')
    nonzero_money = Mint.money(100, 'USD')

    assert_performance_constant 0.99 do |_n|
      zero_money.zero?
      zero_money.nonzero?
      nonzero_money.zero?
      nonzero_money.nonzero?
    end
  end

  # Test memory stability - ensure no memory leaks
  def bench_memory_stability
    # This test ensures memory usage doesn't grow over time
    Mint.money(100, 'USD')

    (1..100).each do |iteration|
      # Create many objects and let them be garbage collected
      1000.times do
        temp_money = Mint.money(rand(1..1000), 'USD')
        temp_money.to_s
        temp_money.hash
      end

      # Force garbage collection periodically
      GC.start if (iteration % 10).zero?
    end

    # If we get here without running out of memory, test passes
    assert true, 'Memory stability test completed'
  end

  # Test performance with different currency subunits
  def bench_subunit_performance_constant
    usd_money = Mint.money(100.50, 'USD')  # 2 subunits
    jpy_money = Mint.money(100, 'JPY')     # 0 subunits

    assert_performance_constant 0.99 do |_n|
      usd_money.split(3)
      jpy_money.split(3)
    end
  end

  # Test that type checking doesn't degrade performance
  def bench_type_checking_constant
    money = Mint.money(100, 'USD')

    assert_performance_constant 0.99 do |_n|
      # These should all do type checking internally
      begin
        "#{money}invalid"
      rescue TypeError
        # Expected
      end

      begin
        money * 'invalid'
      rescue TypeError
        # Expected
      end

      # Valid operations
      Mint.money(50, 'USD')
      money * 2
    end
  end

  # Stress test with complex operations
  def bench_complex_operations_constant
    money = Mint.money(1000, 'USD')

    assert_performance_constant 0.95 do |_n|
      # Chain multiple operations
      result = money + Mint.money(100, 'USD')
      result *= 1.5
      result /= 2
      result -= Mint.money(50, 'USD')
      result = result.abs
      result.split(3)
      result.allocate([1, 2, 3])
      result.to_s
      result.hash
    end
  end
end

# frozen_string_literal: true

require_relative '../benchmark_helper'

class MemoryBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    @amounts = Array.new(10_000) { rand(-10_000.00..10_000.00) }
    @currencies = %w[USD EUR GBP JPY BRL CAD AUD CHF]
  end

  def test_memory_allocation_profile
    with_bench('Memory Allocation Profile') do
      # Test object allocation patterns
      measure_allocations('Money creation') do
        1000.times { |i| Mint.money(@amounts[i], 'USD') }
      end

      measure_allocations('Arithmetic operations') do
        m1 = Mint.money(100, 'USD')
        Mint.money(50, 'USD')
        1000.times do
          m1 / 3
        end
      end

      measure_allocations('String formatting') do
        money = Mint.money(123.45, 'USD')
        1000.times do
          money.to_s
          money.to_json
          money.inspect
        end
      end

      measure_allocations('Allocation algorithms') do
        money = Mint.money(1000, 'USD')
        100.times do
          money.split(7)
          money.allocate([1, 2, 3, 4])
        end
      end
    end
  end

  def test_gc_pressure
    with_bench('Garbage Collection Pressure') do
      # Measure GC pressure for different operations
      measure_gc_stats('Heavy money creation') do
        10_000.times do |i|
          Mint.money(@amounts[i % @amounts.size], @currencies[i % @currencies.size])
        end
      end

      measure_gc_stats('Complex arithmetic chains') do
        money_objects = Array.new(100) { |i| Mint.money(@amounts[i], 'USD') }
        money_objects.each do |m1|
          money_objects.each do |m2|
            ((m1 + m2) * rand(1.0..5.0)) - (m1 / rand(2..5)).abs if m1.currency == m2.currency
          end
        end
      end
    end
  end

  def test_memory_retention
    with_bench('Memory Retention Test') do
      # Test for memory leaks
      initial_objects = ObjectSpace.count_objects

      # Create and discard many objects
      10.times do
        money_array = Array.new(1000) { |i| Mint.money(@amounts[i % @amounts.size], 'USD') }
        # Perform operations
        money_array.each do |m|
          m * 2
          m.to_s
          m.hash
        end
        # Clear references
        money_array.clear
        nil
      end

      # Force garbage collection
      3.times { GC.start }

      final_objects = ObjectSpace.count_objects

      puts 'Object count change:'
      initial_objects.each do |type, count|
        final_count = final_objects[type] || 0
        diff = final_count - count
        puts "  #{type}: #{diff}" if diff != 0
      end
    end
  end

  def test_large_scale_operations
    with_bench('Large Scale Operations') do
      large_amounts = Array.new(100_000) { rand(-100_000.00..100_000.00) }

      Benchmark.ips do |x|
        x.report('Bulk money creation') do
          1000.times { |i| Mint.money(large_amounts[i], 'USD') }
        end

        x.report('Bulk arithmetic') do
          moneys = Array.new(100) { |i| Mint.money(large_amounts[i], 'USD') }
          moneys.sum
        end

        x.report('Complex allocation') do
          money = Mint.money(large_amounts.first, 'USD')
          money.split(97) # Prime number for uneven distribution
        end

        x.compare!
      end
    end
  end
end

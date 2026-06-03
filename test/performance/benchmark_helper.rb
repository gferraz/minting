# frozen_string_literal: true

require_relative '../test_helper'
require 'benchmark'
require 'benchmark/ips'
require 'bigdecimal'
require 'money'

using Mint

module BenchmarkHelper
  def configure_money_gem(rounding: BigDecimal::ROUND_HALF_UP, currency: 'USD')
    Money.rounding_mode = rounding
    Money.default_currency = Money::Currency.new(currency)
  end

  def test_amounts
    @test_amounts ||= [1.00, 10.50, 123.45, 999.99, 1234.56]
  end

  def random_amounts(size: 1000, range: -1000.00..1000.00)
    @random_amounts ||= Array.new(size) { rand(range) }
  end

  def random_amount
    @amount = rand(-1000.00..1000.00)
  end

  def diff(base, final)
    keys = base.keys + final.keys
    keys.uniq!
    keys.sort!
    keys.each_with_object({}) do |key, result|
      delta = final[key].to_i - base[key].to_i
      result[key] = delta if delta.nonzero?
    end
  end

  def run_object_space_profile(times: 1_000)
    GC.start
    before = ObjectSpace.count_objects.dup
    times.times { yield(random_amount) }
    after = ObjectSpace.count_objects.dup
    diff(before, after)
  end

  def run_gc_stat(times: 1_000)
    GC.start
    before = GC.stat.dup
    times.times { yield(random_amount) }
    after = GC.stat.dup
    diff(before, after)
  end

  def with_bench(title)
    skip unless ENV['BENCH']
    puts "\n=== #{title} ==="
    yield
  end

  def measure_object_space(description)
    puts "\n--- #{description} ---"
    GC.start
    before = ObjectSpace.count_objects.dup
    yield
    GC.start
    after = ObjectSpace.count_objects.dup
    after.merge(before) { |_key, after_val, before_val| after_val - before_val }
  end

  def measure_memory_usage(description)
    puts "\n--- #{description} ---"
    mint_diff = measure_object_space("Mint #{description}") { yield(:mint) }
    money_diff = measure_object_space("Money #{description}") { yield(:money) }

    significant_types = (mint_diff.keys + money_diff.keys).uniq.select do |type|
      (mint_diff[type] || 0) > 10 || (money_diff[type] || 0) > 10
    end

    if significant_types.empty?
      puts 'Minimal allocation detected'
    else
      significant_types.sort.each do |type|
        mint_alloc = mint_diff[type] || 0
        money_alloc = money_diff[type] || 0
        ratio = money_alloc.zero? ? 'N/A' : (mint_alloc.to_f / money_alloc).round(2)
        puts "  #{type}: Mint=#{mint_alloc}, Money=#{money_alloc}, Ratio=#{ratio}x"
      end
    end

    { mint: mint_diff, money: money_diff }
  end

  def measure_allocations(description)
    puts "\n--- #{description} ---"
    GC.start
    before = ObjectSpace.count_objects.dup
    yield
    GC.start
    after = ObjectSpace.count_objects.dup
    diff = after.merge(before) { |_key, after_val, before_val| after_val - before_val }
    significant_diff = diff.select { |_key, val| val.positive? && val > 10 }

    if significant_diff.any?
      puts 'Allocated objects:'
      significant_diff.sort_by { |_k, v| -v }.each do |type, count|
        puts "  #{type}: #{count}"
      end
    else
      puts 'Minimal allocation detected'
    end

    diff
  end

  def measure_gc_stats(description)
    puts "\n--- #{description} ---"
    GC.start
    before_stats = GC.stat.dup
    yield
    after_stats = GC.stat.dup

    relevant_stats = %i[count major_gc_count minor_gc_count total_allocated_objects]
    relevant_stats.each do |stat|
      before_val = before_stats[stat] || 0
      after_val = after_stats[stat] || 0
      diff = after_val - before_val
      puts "  #{stat}: #{diff}" if diff.positive?
    end
  end

  module_function :configure_money_gem, :test_amounts, :random_amounts, :random_amount, :diff,
                  :run_object_space_profile, :run_gc_stat, :with_bench, :measure_object_space,
                  :measure_memory_usage, :measure_allocations, :measure_gc_stats
end

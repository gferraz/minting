# frozen_string_literal: true

require_relative '../benchmark_helper'

class BasicIpsBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    configure_money_gem
    @amount = random_amount
  end

  def test_creation_performance
    with_bench('Creation: Mint.money vs Money.new') do
      amount = @amount

      Benchmark.ips do |x|
        x.report('Mint.money') { Mint.money(amount, 'USD') }
        x.report('Money.new') { Money.new(amount * 100, 'USD') }
        x.compare!
      end
    end
  end

  def test_equality_performance
    with_bench('Equality: Mint vs Money') do
      amount = @amount

      Benchmark.ips do |x|
        x.report('Mint equals') do
          m1 = Mint.money(amount, 'USD')
          m2 = Mint.money(amount, 'USD')
          m1 == m2
        end
        x.report('Money equals') do
          m1 = Money.new(amount, 'USD')
          m2 = Money.new(amount, 'USD')
          m1 == m2
        end
        x.compare!
      end
    end
  end

  def test_arithmetic_performance
    with_bench('Arithmetic: Mint vs Money') do
      amount = @amount

      Benchmark.ips do |x|
        x.report('Mint arithmetics') do
          m1 = Mint.money(amount, 'USD')
          m2 = Mint.money(amount, 'USD')
          m1 + m2 + (m2 * 5) - (m2 / 2).abs
        end
        x.report('Money arithmetics') do
          m1 = Money.new(amount, 'USD')
          m2 = Money.new(amount, 'USD')
          m1 + m2 + (m2 * 5) - (m2 / 2).abs
        end
        x.compare!
      end
    end
  end

  def test_object_space_profile
    with_bench('Object Space Profile') do
      run_object_space_profile { |a| Mint.money(a, 'USD') }
      run_object_space_profile { |a| Money.new(a * 100, 'USD') }
    end
  end

  def test_gc_profiling
    with_bench('GC Profiling') do
      GC.start
      GC::Profiler.enable
      GC.start
      puts GC::Profiler.report
      GC::Profiler.disable
    end
  end

  def test_ruby_prof
    with_bench('RubyProf') do
      require 'ruby-prof'

      result = RubyProf::Profile.profile do
        1_000.times { Mint.money(random_amount, 'USD') }
      end

      printer = RubyProf::GraphPrinter.new(result)
      printer.print
    end
  end
end

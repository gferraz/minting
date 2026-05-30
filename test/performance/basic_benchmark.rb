require_relative 'benchmark_helper'

class BasicBenchmark < Minitest::Benchmark
  include BenchmarkHelper

  def setup
    configure_money_gem
    @amount = BenchmarkHelper.random_amount
  end

  def self.bench_range
    bench_exp(10, 10_000) << 25_000
  end

  def bench_money_mint
    assert_performance_constant 0.99 do |_n|
      Mint.money(0, 'USD')
    end
  end
end

Benchmark.ips do |x|
  x.report('Mint.money') { Mint.money(@amount, 'USD') }
  x.report('Money.new') { Money.new(@amount * 100, 'USD') }
  x.compare!
end

Benchmark.ips do |x|
  x.report('Mint equals') do
    m1 = Mint.money(@amount, 'USD')
    m2 = Mint.money(@amount, 'USD')
    m1 == m2
  end
  x.report('Money equals') do
    m1 = Money.new(@amount, 'USD')
    m2 = Money.new(@amount, 'USD')
    m1 == m2
  end
  x.compare!
end

Benchmark.ips do |x|
  x.report('Mint arithmetics') do
    m1 = Mint.money(@amount, 'USD')
    m2 = Mint.money(@amount, 'USD')
    m1 + m2 + (m2 * 5) - (m2 / 2).abs
  end
  x.report('Money arithmetics') do
    m1 = Money.new(@amount, 'USD')
    m2 = Money.new(@amount, 'USD')
    m1 + m2 + (m2 * 5) - (m2 / 2).abs
  end
  x.compare!
end

BenchmarkHelper.run_object_space_profile { |amount| Mint.money(amount, 'USD') }
BenchmarkHelper.run_object_space_profile { |amount| Money.new(amount * 100, 'USD') }

GC.start # clear GC before profiling
GC::Profiler.enable
GC.start
puts GC::Profiler.report
GC::Profiler.disable

require 'ruby-prof'

# profile the code
result = RubyProf::Profile.profile do
  1_000.times do
    Mint.money(BenchmarkHelper.random_amount, 'USD')
  end
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print

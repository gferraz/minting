require 'test_helper'
require 'bigdecimal'
class MintBenchmark < Minitest::Benchmark
  def self.bench_range
    bench_exp(10, 10_000) << 25_000
  end

  def bench_money_mint
    assert_performance_constant 0.99 do |_n|
      Mint.money(0, 'USD')
    end
  end
end

require 'benchmark/ips'
require 'money'
require 'minting'

def random_amount
  rand(-1000.00..1000.00)
end

Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

Benchmark.ips do |x|
  x.report('Mint.money') { Mint.money(random_amount, 'USD') }
  x.report('Money.new') { Money.new(random_amount * 100, 'USD') }
  x.compare!
end

Benchmark.ips do |x|
  x.report('Mint equals') do
    m1 = Mint.money(random_amount, 'USD')
    m2 = Mint.money(random_amount, 'USD')
    m1 == m2
    m1 == m1
  end
  x.report('Money equals') do
    m1 = Money.new(random_amount, 'USD')
    m2 = Money.new(random_amount, 'USD')
    m1 == m2
    m1 == m1
  end
  x.compare!
end

Benchmark.ips do |x|
  x.report('Mint arithmetics') do
    m1 = Mint.money(random_amount, 'USD')
    m2 = Mint.money(random_amount, 'USD')
    m1 + m2 + (m2 * 5) - (m2 / 2).abs
  end
  x.report('Money arithmetics') do
    m1 = Money.new(random_amount, 'USD')
    m2 = Money.new(random_amount, 'USD')
    m1 + m2 + (m2 * 5) - (m2 / 2).abs
  end
  x.compare!
end

TIMES = 1_000
AMOUNTS = Array.new(TIMES) { rand(-1000.00..1000.00) }

def diff(base, final)
  keys = base.keys + final.keys
  keys.uniq!
  keys.sort!
  dif = {}
  keys.each do |key|
    d = final[key].to_i - base[key].to_i
    dif[key] = d if d.nonzero?
  end
  dif
end

def run
  GC.start # clear GC before profiling
  base = ObjectSpace.count_objects.dup

  TIMES.times do
    yield(random_amount)
  end
  final = ObjectSpace.count_objects.dup
  diff(base, final)
end

def run_stat
  GC.start # clear GC before profiling
  base = GC.stat.dup

  TIMES.times do
    yield(random_amount)
  end
  final = GC.stat.dup
  diff(base, final)
end

mi = run { Mint.money(random_amount, 'USD') }
mo = run { Money.new(random_amount * 100, 'USD') }

GC.start # clear GC before profiling
GC::Profiler.enable
GC.start
puts GC::Profiler.report
GC::Profiler.disable

require 'ruby-prof'

# profile the code
result = RubyProf::Profile.profile  do
  TIMES.times do
    Mint.money(random_amount, 'USD')
  end
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})

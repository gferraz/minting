# require 'test_helper'
#
# class MintBenchmark < Minitest::Benchmark
#   def self.bench_range
#     bench_exp(10, 10_000) << 25_000
#   end
#
#   def bench_money_mint
#     assert_performance_constant 0.99 do |_n|
#       Mint.money(0, :USD)
#     end
#   end
# end
#
# require 'benchmark/ips'
# require 'money'
# require 'minting'
#
# Benchmark.ips do |x|
#   usd = Mint.new(:USD)
#   # x.report("mint.money") { usd.money(rand(-100.00..100.00)) }
#   # x.report("Money.new") { Money.new(rand(-100.00..100.00), :USD) }
#   # x.compare!
#
#   def amount
#     rand(-10.00..10.00)
#   end
#
#   x.report('mint.money') { Mint.money(amount, :USD) }
#   x.report('Money.new') { Money.new(amount * 100, :USD) }
#   x.compare!
# end
#
# TIMES = 1_000
# AMOUNTS = Array.new(TIMES) { rand(-1000.00..1000.00) }
#
# def diff(base, final)
#   keys = base.keys + final.keys
#   keys.uniq!
#   keys.sort!
#   dif = {}
#   keys.each do |key|
#     d = final[key].to_i - base[key].to_i
#     dif[key] = d if d.nonzero?
#   end
#   dif
# end
#
# def run
#   GC.start # clear GC before profiling
#   base = ObjectSpace.count_objects.dup
#
#   TIMES.times do
#     yield(amount)
#   end
#   final = ObjectSpace.count_objects.dup
#   diff(base, final)
# end
#
# def run_stat
#   GC.start # clear GC before profiling
#   base = GC.stat.dup
#
#   TIMES.times do
#     yield(amount)
#   end
#   final = GC.stat.dup
#   diff(base, final)
# end
#
# mi = run { Mint.money(amount, :USD) }
# mo = run { Money.new(amount * 100, :USD) }
#
# GC.start # clear GC before profiling
# GC::Profiler.enable
# GC.start
# puts GC::Profiler.report
# GC::Profiler.disable
#
# require 'money'
# require 'minting'
# require 'ruby-prof'
#
# # profile the code
# result = RubyProf.profile do
#   TIMES.times do
#     Mint.money(amount, :USD)
#   end
# end
#
# # print a graph profile to text
# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, {})

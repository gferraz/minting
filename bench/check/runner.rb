# frozen_string_literal: true

require 'minting'
require 'benchmark'
require 'json'

unless RUBY_VERSION.start_with?('4.')
  puts "Benchmarks are only supported on Ruby 4.x (current: #{RUBY_VERSION}). Skipping."

  output = {
    metadata: { ruby_version: RUBY_VERSION, ruby_platform: RUBY_PLATFORM },
    results: { no_rounding: {}, half_down: {} }
  }
  json = JSON.pretty_generate(output)
  puts json
  File.write(ARGV.first, json) if ARGV.first
  exit 0
end

ITERS = {
  creation: 500_000,
  copy_with: 500_000,

  addition: 500_000,
  subtraction: 500_000,
  multiplication: 500_000,
  division: 500_000,
  divisionby_f: 500_000,
  ratio: 500_000,

  comparison: 500_000,
  formatting: 200_000,
  to_s: 200_000,
  parsing: 200_000,
  split: 200_000,
  allocate: 200_000,
  from_hash: 200_000,
}.freeze

MODES = {
  no_rounding: nil,
  half_down: :half_down
}.freeze

m1 = 123.45.dollars
m2 = -67.89.dollars
split_money = 100.dollars
parse_inputs = ['$19.99', 'USD 1,234.56', '19,99 €', '¥1500']
parse_count = parse_inputs.size
from_hash_input = { currency: 'USD', amount: '123.45' }


bench_block = lambda do |name, n|
  case name
  when :creation       then n.times { Mint.money(123.45, 'USD') }
  when :copy_with      then n.times { m1.copy_with(amount: 23.22) }

  when :addition       then n.times { m1 + m2 }
  when :subtraction    then n.times { m1 - m2 }
  when :multiplication then n.times { m1 * 2 }
  when :division       then n.times { m1 / 2 }
  when :division_by_f  then n.times { m1 / 2.45 }
  when :ratio          then n.times { m1 / m2 }
  when :comparison     then n.times { m1 == m2 }

  when :formatting     then n.times { m2.format(:accounting) }
  when :to_s           then n.times { m1.to_s }
  when :parsing        then (n / parse_count).times { parse_inputs.each { |s| Mint.parse(s) } }
  when :split          then n.times { split_money.split(12) }
  when :allocate       then n.times { split_money.allocate((1..24).to_a) }
  when :from_hash      then n.times { Mint::Money.from_hash(from_hash_input) }

  end
end

output = {
  metadata: {
    gem_version: Minting::VERSION,
    generated_at: Time.now.utc.iso8601,
    ruby_version: RUBY_VERSION,
    ruby_platform: RUBY_PLATFORM
  },
  results: {}
}

MODES.each do |mode_name, rounding_mode|
  GC.start
  results = {}

  ITERS.each do |name, n|
    GC.start
    real = if rounding_mode
             Benchmark.measure { Mint.with_rounding(rounding_mode) { bench_block.call(name, n) } }.real
           else
             Benchmark.measure { bench_block.call(name, n) }.real
           end

    results[name.to_s] = { ips: (n / real).round, elapsed: real.round(4) }
  end

  output[:results][mode_name.to_s] = results
end

json = JSON.pretty_generate(output)
puts json

File.write(ARGV.first, json) if ARGV.first

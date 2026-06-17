# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveAllocationBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @scenarios = [
      { amount: 15.01, desc: 'small_amount' },
      { amount: 12_343.47, desc: 'large_amount' }
    ]

    @patterns = [
      [1, 2, 3],
      [0.25, 1.25, 2.25, 3.25],
      (1..60).to_a
    ]
  end

  def test_allocation
    with_bench('Allocation Algorithms: Minting vs Money Gem') do
      @scenarios.each do |scenario|
        puts "\n--- #{scenario[:desc]} (#{scenario[:amount]}) ---"

        mint_money = Mint.money(scenario[:amount], 'USD')
        money = Money.from_amount(scenario[:amount], 'USD')

        @patterns.each_with_index do |pattern, index|
          puts "\nPattern #{index + 1}: #{pattern}"

          Benchmark.ips do |x|
            x.report('Mint allocate') { mint_money.allocate(pattern) }
            x.report('Money allocate') { money.allocate(pattern) }
            x.compare!
          end
        end
      end
    end
  end

  def test_split
    with_bench('Splitting Algorithms: Minting vs Money Gem') do
      @scenarios.each do |scenario|
        puts "\n--- #{scenario[:desc]} (#{scenario[:amount]}) ---"

        mint_money = Mint.money(scenario[:amount], 'USD')
        money = Money.from_amount(scenario[:amount], 'USD')

        @patterns.each do |pattern|
          splits = pattern.sum.to_i
          puts "\nSplits: #{splits}"

          Benchmark.ips do |x|
            x.report('Mint split') { mint_money.split(splits) }
            x.report('Money split') { money.split(splits) }

            x.compare!
          end
        end
      end
    end
  end
end

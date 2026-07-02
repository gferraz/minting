# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveComparisonBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @mint_a = Mint::Money.from(100.00, 'USD')
    @mint_b = Mint::Money.from(100.00, 'USD')
    @mint_c = Mint::Money.from(50.00, 'USD')
    @mint_d = Mint::Money.from(100.00, 'EUR')

    @money_a = Money.from_amount(100.00, 'USD')
    @money_b = Money.from_amount(100.00, 'USD')
    @money_c = Money.from_amount(50.00, 'USD')
    @money_d = Money.from_amount(100.00, 'EUR')
  end

  def test_equality_and_comparison
    with_bench('Equality and Comparison: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint == same') { @mint_a == @mint_b }
        x.report('Money == same') { @money_a == @money_b }
        x.report('Mint == different') { @mint_a == @mint_c }
        x.report('Money == different') { @money_a == @money_c }
        x.report('Mint == different currency') { @mint_a == @mint_d }
        x.report('Money == different currency') { @money_a == @money_d }
        x.report('Mint >') { @mint_a > @mint_c }
        x.report('Money >') { @money_a > @money_c }
        x.compare!
      end
    end
  end

  def test_hash
    with_bench('Hash function: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint hash') { @mint_a.hash }
        x.report('Money hash') { @money_a.hash }
        x.compare!
      end
    end
  end

  def test_spaceship
    with_bench('Spaceship operator: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint <=>') { @mint_a <=> @mint_c }
        x.report('Money <=>') { @money_a <=> @money_c }
        x.compare!
      end
    end
  end
end

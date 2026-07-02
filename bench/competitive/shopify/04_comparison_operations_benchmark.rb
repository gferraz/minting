# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveComparisonBenchmark < Minitest::Test
  include BenchmarkHelper
  include ShopifyBenchHelper

  def setup
    configure_shopify_money_gem
    @mint_a = Mint::Money.from(100.00, 'USD')
    @mint_b = Mint::Money.from(100.00, 'USD')
    @mint_c = Mint::Money.from(50.00, 'USD')
    @mint_d = Mint::Money.from(100.00, 'EUR')

    @money_a = Money.new(100.00, 'USD')
    @money_b = Money.new(100.00, 'USD')
    @money_c = Money.new(50.00, 'USD')
    @money_d = Money.new(100.00, 'EUR')
  end

  def test_equality_and_comparison
    with_bench('Equality and Comparison: Minting vs Shopify Money') do
      Benchmark.ips do |x|
        x.report('Mint == same') { @mint_a == @mint_b }
        x.report('Shopify == same') { @money_a == @money_b }
        x.report('Mint == different') { @mint_a == @mint_c }
        x.report('Shopify == different') { @money_a == @money_c }
        x.report('Mint == different currency') { @mint_a == @mint_d }
        x.report('Shopify == different currency') { @money_a == @money_d }
        x.report('Mint >') { @mint_a > @mint_c }
        x.report('Shopify >') { @money_a > @money_c }
        x.compare!
      end
    end
  end

  def test_hash
    with_bench('Hash function: Minting vs Shopify Money') do
      Benchmark.ips do |x|
        x.report('Mint hash') { @mint_a.hash }
        x.report('Shopify hash') { @money_a.hash }
        x.compare!
      end
    end
  end

  def test_spaceship
    with_bench('Spaceship operator: Minting vs Shopify Money') do
      Benchmark.ips do |x|
        x.report('Mint <=>') { @mint_a <=> @mint_c }
        x.report('Shopify <=>') { @money_a <=> @money_c }
        x.compare!
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveMemoryBenchmark < Minitest::Test
  include BenchmarkHelper
  include ShopifyBenchHelper

  def setup
    configure_shopify_money_gem
    @random_amounts = random_amounts
  end

  def test_memory_usage_comparison
    with_bench('Memory Usage: Minting vs Shopify Money') do
      iterations = 10_000

      measure_memory_usage("Object Creation - #{iterations} objects") do |library|
        case library
        when :mint
          iterations.times { |i| Mint.money(@random_amounts[i % @random_amounts.size], 'USD') }
        when :money
          iterations.times do |i|
            Money.from_amount(@random_amounts[i % @random_amounts.size], 'USD')
          end
        end
      end

      measure_memory_usage("Arithmetic Operations - #{iterations} operations") do |library|
        case library
        when :mint
          money1 = Mint.money(100, 'USD')
          money2 = Mint.money(50, 'USD')
          iterations.times { ((money1 + money2) * 2) - (money1 / 3) }
        when :money
          money1 = Money.from_amount(100, 'USD')
          money2 = Money.from_amount(50, 'USD')
          iterations.times { ((money1 + money2) * 2) - (money1 / 3) }
        end
      end
    end
  end
end

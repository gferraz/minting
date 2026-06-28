# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveObjectCreationBenchmark < Minitest::Test
  include BenchmarkHelper
  include ShopifyBenchHelper

  def setup
    configure_shopify_money_gem
    @amount = 1234.56
  end

  def test_object_creation
    with_bench('Object Creation: Minting vs Shopify Money') do
      Benchmark.ips do |x|
        x.report('Mint.money') { Mint.money(@amount, 'USD') }
        x.report('Mint some.dollars') { @amount.dollars }
        x.report('Mint.from_subunits') { Mint.money((@amount * 100).to_i, 'USD') }
        x.report('Shopify Money.new') { Money.from_amount(@amount, 'USD') }
        x.compare!
      end
    end
  end
end

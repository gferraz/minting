# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveCurrencyLookupBenchmark < Minitest::Test
  include BenchmarkHelper
  include ShopifyBenchHelper

  def setup
    configure_shopify_money_gem
  end

  def test_currency_lookup
    with_bench('Currency Lookup: Minting vs Shopify Money') do
      Benchmark.ips do |x|
        x.report('Mint currency') { Mint::Currency.for_code('USD') }
        x.report('Shopify currency') { Money::Currency.find('USD') }
        x.compare!
      end
    end
  end
end

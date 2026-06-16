# frozen_string_literal: true

require_relative '../benchmark_helper'

class CompetitiveCurrencyLookupBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    configure_money_gem
  end

  def test_currency_lookup
    with_bench('Currency Lookup: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint currency') { Currency.for_code('USD') }
        x.report('Money currency') { Money::Currency.find('USD') }
        x.compare!
      end
    end
  end
end

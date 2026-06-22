# frozen_string_literal: true

require_relative 'benchmark_helper'

using Mint

class CompetitiveObjectCreationBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @amount = 1234.56
  end

  def test_object_creation
    with_bench('Object Creation: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint.money') { Mint.money(@amount, 'USD') }
        x.report('Mint some.dollars') { @amount.dollars }
        x.report('Mint.from_subunits') { Mint.money((@amount * 100).to_i, 'USD') }
        x.report('Money.new') { Money.new((@amount * 100).to_i, 'USD') }
        x.report('Money.from_amount') { Money.from_amount(@amount, 'USD') }
        x.compare!
      end
    end
  end
end

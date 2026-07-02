# frozen_string_literal: true

require_relative 'benchmark_helper'

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
        x.report('Mint::Money.from') { Mint::Money.from(@amount, 'USD') }
        x.report('Mint some.dollars') { @amount.dollars }
        cents = (@amount * 100).to_i
        x.report('Mint::Money.from_subunits') { Mint::Money.from_subunits(cents, 'USD') }

        x.report('Money.new') { Money.new(cents, 'USD') }
        x.report('Money.from_amount') { Money.from_amount(@amount, 'USD') }
        x.compare!
      end
    end
  end
end

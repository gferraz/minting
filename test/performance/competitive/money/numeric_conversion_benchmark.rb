# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveNumericConversionBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @amount = 22_123_678.232
    @mint_money = Mint.money(@amount, 'USD')
    @money = Money.from_amount(@amount, 'USD')
  end

  def test_numeric_conversion
    with_bench('Numeric Conversion: Minting vs Money') do
      puts "\nAmount: #{@amount}"

      Benchmark.ips do |x|
        x.report('Mint to_i') { @mint_money.to_i }
        x.report('Money to_i') { @money.to_i }
        x.report('Mint to_f') { @mint_money.to_f }
        x.report('Money to_f') { @money.to_f }
        x.report('Mint to_r') { @mint_money.to_r }
        x.report('Mint to_d') { @mint_money.to_d }
        x.report('Money to_d') { @money.to_d }
        x.compare!
      end
    end
  end
end

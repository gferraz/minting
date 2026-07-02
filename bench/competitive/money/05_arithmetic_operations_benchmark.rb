# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveArithmeticBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @mint1 = Mint::Money.from(100.50, 'USD')
    @mint2 = Mint::Money.from(50.25, 'USD')
    @money1 = Money.from_amount(100.50, 'USD')
    @money2 = Money.from_amount(50.25, 'USD')
  end

  def test_addition
    with_bench('Addition: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint addition') { @mint1 + @mint2 }
        x.report('Money addition') { @money1 + @money2 }
        x.compare!
      end
    end
  end

  def test_subtraction
    with_bench('Subtraction: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint subtraction') { @mint1 - @mint2 }
        x.report('Money subtraction') { @money1 - @money2 }
        x.compare!
      end
    end
  end

  def test_multiplication_and_division
    with_bench('Multiplication/Division: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint multiply') { @mint1 * 3.5 }
        x.report('Money multiply') { @money1 * 3.5 }
        x.report('Mint divide scalar') { @mint1 / 2.5 }
        x.report('Money divide scalar') { @money1 / 2.5 }
        x.report('Mint divide ratio') { @mint1 / @mint2 }
        x.report('Money divide ratio') { @money1 / @money2 }
        x.compare!
      end
    end
  end

  def test_negation_and_abs
    with_bench('Negation/Absolute: Minting vs Money Gem') do
      Benchmark.ips do |x|
        x.report('Mint negation') { -@mint1 }
        x.report('Money negation') { -@money1 }
        x.report('Mint abs') { (-@mint1).abs }
        x.report('Money abs') { (-@money1).abs }
        x.compare!
      end
    end
  end
end

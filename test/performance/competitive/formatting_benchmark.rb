# frozen_string_literal: true

require_relative '../benchmark_helper'

class CompetitiveFormattingBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    configure_money_gem
    @test_amounts = test_amounts
  end

  def test_formatting_methods
    with_bench('String Formatting: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        mint_money = Mint.money(amount, 'USD')
        money = Money.from_amount(amount, 'USD')

        puts "\nAmount: #{amount}"

        Benchmark.ips do |x|
          x.report('Mint to_s') { mint_money.to_s }
          x.report('Money to_s') { money.to_s }
          x.report('Mint inspect') { mint_money.inspect }
          x.report('Money inspect') { money.inspect }
          x.compare!
        end
      end
    end
  end

  def test_json_formatting_methods
    with_bench('String Formatting: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        mint_money = Mint.money(amount, 'USD')
        money = Money.from_amount(amount, 'USD')

        puts "\nAmount: #{amount}"

        Benchmark.ips do |x|
          x.report('Mint to_json') { mint_money.to_json }
          x.report('Money to_json') { money.to_json }
          x.compare!
        end
      end
    end
  end
end

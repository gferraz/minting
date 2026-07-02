# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveHighVolumeBenchmark < Minitest::Test
  include BenchmarkHelper
  include ShopifyBenchHelper

  def setup
    configure_shopify_money_gem
    @transaction_count = 50_000
    @amounts = Array.new(@transaction_count) { rand(1.00..1000.00) }
  end

  def test_high_volume_transactions
    with_bench('High Volume Transaction Simulation') do
      puts "\nProcessing #{@transaction_count} transactions..."

      mint_time = Benchmark.realtime do
        running_total = Mint::Money.from(0, 'USD')
        @amounts.each do |amount|
          transaction = Mint::Money.from(amount, 'USD')
          running_total += transaction
          fee = transaction * 0.029
          transaction - fee
        end
      end

      money_time = Benchmark.realtime do
        running_total = Money.new(0, 'USD')
        @amounts.each do |amount|
          transaction = Money.new(amount, 'USD')
          running_total += transaction
          fee = transaction * 0.029
          transaction - fee
        end
      end

      puts "  Mint time: #{(mint_time * 1000).round(2)}ms"
      puts "  Shopify time: #{(money_time * 1000).round(2)}ms"
      puts "  Mint ops/sec: #{(@transaction_count / mint_time).round(0)}"
      puts "  Shopify ops/sec: #{(@transaction_count / money_time).round(0)}"
      puts "  Performance ratio: #{(money_time / mint_time).round(2)}x"
    end
  end
end

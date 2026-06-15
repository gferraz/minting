# frozen_string_literal: true

require_relative '../benchmark_helper'

using Mint

class CompetitiveHighVolumeBenchmark < Minitest::Test
  include BenchmarkHelper

  def setup
    configure_money_gem
    @transaction_count = 50_000
    @amounts = Array.new(@transaction_count) { rand(1.00..1000.00) }
  end

  def test_high_volume_transactions
    with_bench('High Volume Transaction Simulation') do
      puts "\nProcessing #{@transaction_count} transactions..."

      mint_time = Benchmark.realtime do
        running_total = Mint.money(0, 'USD')
        @amounts.each do |amount|
          transaction = Mint.money(amount, 'USD')
          running_total += transaction
          fee = transaction * 0.029
          transaction - fee
        end
      end

      money_time = Benchmark.realtime do
        running_total = Money.from_amount(0, 'USD')
        @amounts.each do |amount|
          transaction = Money.from_amount(amount, 'USD')
          running_total += transaction
          fee = transaction * 0.029
          transaction - fee
        end
      end

      puts "  Mint time: #{(mint_time * 1000).round(2)}ms"
      puts "  Money time: #{(money_time * 1000).round(2)}ms"
      puts "  Mint ops/sec: #{(@transaction_count / mint_time).round(0)}"
      puts "  Money ops/sec: #{(@transaction_count / money_time).round(0)}"
      puts "  Performance ratio: #{(money_time / mint_time).round(2)}x"
    end
  end
end

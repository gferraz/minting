# frozen_string_literal: true

require_relative 'benchmark_helper'

class CompetitiveFormattingBenchmark < Minitest::Test
  include BenchmarkHelper
  include MoneyBenchHelper

  def setup
    configure_money_gem
    @test_amounts = [test_amounts[0], test_amounts[-1]]
  end

  def test_formatting_methods
    with_bench('String Formatting: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        mint_money = Mint::Money.from(amount, 'USD')
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

  def test_custom_format_variants
    with_bench('Custom Format: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        mint_money = Mint::Money.from(amount, 'USD')
        money = Money.from_amount(amount, 'USD')

        puts "\nAmount: #{amount}"

        Benchmark.ips do |x|
          x.report('Mint format') { mint_money.format }
          x.report('Money format') { money.format }
          x.report('Mint format currency') { mint_money.format('%<amount>f %<currency>s') }
          x.report('Money format currency') { money.format(with_currency: true) }
          x.report('Mint format thousand') { mint_money.format(thousand: ',') }
          x.report('Money format thousand') { money.format(thousands_separator: ',') }
          x.report('Mint format decimal comma') { mint_money.format(decimal: ',', thousand: '.') }
          x.report('Money format decimal comma') { money.format(decimal_mark: ',', thousands_separator: '.') }
          x.report('Mint format custom template') { mint_money.format('%<symbol>s %<amount>f') }
          x.report('Money format custom template') { money.format(format: '%u %n') }
          x.compare!
        end
      end
    end
  end

  def test_formatting_rules
    with_bench('Formatting Rules: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        mint_money = Mint::Money.from(amount, 'USD')
        money = Money.from_amount(amount, 'USD')

        puts "\nAmount: #{amount}"

        Benchmark.ips do |x|
          x.report('Mint no cents') { mint_money.format('%<symbol>s%<integral>d') }
          x.report('Money no cents') { money.format(no_cents: true) }
          x.report('Mint no symbol') { mint_money.format('%<amount>f') }
          x.report('Money no symbol') { money.format(symbol: false) }
          x.report('Mint sign positive') { mint_money.format('%<symbol>s%<amount>+f') }
          x.report('Money sign positive') { money.format(sign_positive: true) }
          x.report('Mint disambiguate') { mint_money.format('%<dsymbol>s%<amount>f') }
          x.report('Money disambiguate') { money.format(disambiguate: true) }
          x.compare!
        end
      end
    end
  end

  def test_json_formatting_methods
    with_bench('String Formatting: Minting vs Money Gem') do
      @test_amounts.each do |amount|
        Mint::Money.from(amount, 'USD')
        Money.from_amount(amount, 'USD')

        puts "\nAmount: #{amount}"
      end
    end
  end
end

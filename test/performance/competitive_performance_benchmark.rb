require 'test_helper'
require 'benchmark'
require 'benchmark/ips'
require 'money'
require 'bigdecimal'

using Mint

class CompetitivePerformanceBenchmark < Minitest::Test
  def setup
    # Configure Money gem for fair comparison
    Money.rounding_mode = BigDecimal::ROUND_HALF_UP
    Money.default_currency = Money::Currency.new('USD')

    @test_amounts = [1.00, 10.50, 123.45, 999.99, 1234.56]
    @random_amounts = Array.new(1000) { rand(-1000.00..1000.00) }
  end

  def test_object_creation_comparison
    skip unless ENV['BENCH']

    puts "\n=== Object Creation: Minting vs Money Gem ==="
    amount = 1234.56

    Benchmark.ips do |x|
      x.report('Mint.money') { Mint.money(amount, 'USD') }
      x.report('Mint some.dollars') { amount.dollars }
      x.report('Money.new') { Money.new((amount * 100).to_i, 'USD') }
      x.report('Money.us_dollar') { Money.us_dollar(amount) }
      x.report('Money.from_amount') { Money.from_amount(amount, 'USD') }
      x.compare!
    end
  end

  def test_arithmetic_operations_comparison
    skip unless ENV['BENCH']
    puts "\n=== Arithmetic Operations: Minting vs Money Gem ==="

    mint_money_1 = Mint.money(100.50, 'USD')
    mint_money_2 = Mint.money(50.25, 'USD')

    money_1 = Money.from_amount(100.50, 'USD')
    money_2 = Money.from_amount(50.25, 'USD')

    operations = {
      'addition' => proc { |m1, m2| m1 + m2 },
      'subtraction' => proc { |m1, m2| m1 - m2 },
      'multiplication' => proc { |m1, _m2| m1 * 3.5 },
      'scalar division' => proc { |m1, _m2| m1 / 2.5 },
      'ratio division' => proc { |m1, m2| m1 / m2 },
      'negation' => proc { |m1, _m2| -m1 },
      'absolute' => proc { |m1, _m2| (-m1).abs }
    }

    operations.each do |op_name, operation|
      puts "\n--- #{op_name.capitalize} ---"

      Benchmark.ips do |x|
        x.report("Mint #{op_name}") { operation.call(mint_money_1, mint_money_2) }
        x.report("Money #{op_name}") { operation.call(money_1, money_2) }
        x.compare!
      end
    end
  end

  def test_comparison_operations_comparison
    skip unless ENV['BENCH']
    puts "\n=== Comparison Operations: Minting vs Money Gem ==="

    mint_money_1 = Mint.money(100.00, 'USD')
    mint_money_2 = Mint.money(100.00, 'USD')
    mint_money_3 = Mint.money(50.00, 'USD')

    money_1 = Money.from_amount(100.00, 'USD')
    money_2 = Money.from_amount(100.00, 'USD')
    money_3 = Money.from_amount(50.00, 'USD')

    comparisons = {
      'equality_same' => proc { |m1, m2, _m3| m1 == m2 },
      'equality_different' => proc { |m1, _m2, m3| m1 == m3 },
      'spaceship' => proc { |m1, _m2, m3| m1 <=> m3 },
      'greater_than' => proc { |m1, _m2, m3| m1 > m3 },
      'hash_generation' => proc { |m1, _m2, _m3| m1.hash }
    }

    comparisons.each do |comp_name, comparison|
      skip unless ENV['BENCH']

      puts "\n--- #{comp_name.humanize} ---"

      Benchmark.ips do |x|
        x.report("Mint #{comp_name}") { comparison.call(mint_money_1, mint_money_2, mint_money_3) }
        x.report("Money #{comp_name}") { comparison.call(money_1, money_2, money_3) }
        x.compare!
      end
    end
  end

  def test_formatting_comparison
    skip unless ENV['BENCH']
    puts "\n=== String Formatting: Minting vs Money Gem ==="
    @test_amounts.each do |amount|
      mint_money = Mint.money(amount, 'USD')
      money = Money.from_amount(amount, 'USD')

      puts "\nAmount: #{amount}"

      Benchmark.ips do |x|
        x.report('Mint to_s') { mint_money.to_s }
        x.report('Money to_s') { money.to_s }
        x.report('Mint inspect') { mint_money.inspect }
        x.report('Money inspect') { money.inspect }
        x.report('Mint to_json') { mint_money.to_json }
        x.report('Money to_json') { money.to_json }
        x.report('Mint to_d') { mint_money.to_d }
        x.report('Money to_d') { money.to_d }
        x.report('Mint to_f') { mint_money.to_f }
        x.report('Money to_f') { money.to_f }
        x.compare!
      end
    end
  end

  def test_numeric_comparison
    skip unless ENV['BENCH']
    puts "\n=== Numeric Conversion: Minting vs Money ==="
    amount = 22_123_678.232

    mint_money = Mint.money(amount, 'USD')
    money = Money.from_amount(amount, 'USD')

    puts "\nAmount: #{amount}"

    Benchmark.ips do |x|
      x.report('Mint to_i') { mint_money.to_i }
      x.report('Money to_i') { money.to_i }
      x.report('Mint to_f') { mint_money.to_f }
      x.report('Money to_f') { money.to_f }
      x.report('Mint to_r') { mint_money.to_r }
      x.report('Mint to_d') { mint_money.to_d }
      x.report('Money to_d') { money.to_d }

      x.compare!
    end
  end

  def test_currency_lookup_comparison
    skip unless ENV['BENCH']
    puts "\n=== Currency Lookup: Minting vs Money Gem ==="

    Benchmark.ips do |x|
      x.report('Mint currency(string)') { Mint.currency('USD') }
      x.report('Mint currency(symbol)') { Mint.currency(:USD) }
      x.report('Money currency(new)') { Money::Currency.new('USD') }
      x.report('Money currency(iso_code)') { Money::Currency.find('USD') }
      x.compare!
    end
  end

  def test_allocation_comparison
    skip unless ENV['BENCH']
    puts "\n=== Allocation Algorithms: Minting vs Money Gem ==="

    test_scenarios = [
      { amount: 15.01, desc: 'small_amount' },
      { amount: 12_343.47, desc: 'large_amount' }
    ]

    allocation_patterns = [
      [1, 2, 3],
      [0.25, 1.25, 2.25, 3.25],
      (1..10).to_a
    ]

    test_scenarios.each do |scenario|
      puts "\n--- #{scenario[:desc].humanize} (#{scenario[:amount]}) ---"

      mint_money = Mint.money(scenario[:amount], 'USD')
      money = Money.from_amount(scenario[:amount], 'USD')

      allocation_patterns.each_with_index do |pattern, index|
        splits = pattern.sum.to_i
        puts "\nPattern #{index + 1}: #{pattern} Splits: #{splits}"

        Benchmark.ips do |x|
          x.report('Mint allocate') { mint_money.allocate(pattern) }
          x.report('Money allocate') { money.allocate(pattern) }

          splits = pattern.sum.to_i
          x.report('Mint split') { mint_money.split(splits) }
          x.report('Money split') { money.split(splits) }

          x.compare!
        end
      end
    end
  end

  def test_high_volume_transactions
    skip unless ENV['BENCH']

    puts "\n=== High Volume Transaction Simulation ==="

    # Simulate processing many transactions
    transaction_count = 50_000
    amounts = Array.new(transaction_count) { rand(1.00..1000.00) }

    puts "\nProcessing #{transaction_count} transactions..."
    # Minting performance
    mint_time = Benchmark.realtime do
      running_total = Mint.money(0, 'USD')
      amounts.each do |amount|
        transaction = Mint.money(amount, 'USD')
        running_total += transaction
        fee = transaction * 0.029
        transaction - fee
      end
    end

    # Money gem performance
    money_time = Benchmark.realtime do
      running_total = Money.from_amount(0, 'USD')
      amounts.each do |amount|
        transaction = Money.from_amount(amount, 'USD')
        running_total += transaction
        fee = transaction * 0.029
        transaction - fee
      end
    end

    puts "  Mint time: #{(mint_time * 1000).round(2)}ms"
    puts "  Money time: #{(money_time * 1000).round(2)}ms"
    puts "  Mint ops/sec: #{(transaction_count / mint_time).round(0)}"
    puts "  Money ops/sec: #{(transaction_count / money_time).round(0)}"
    puts "  Performance ratio: #{(money_time / mint_time).round(2)}x"
  end
end

# Helper method for string formatting
class String
  def humanize
    tr('_', ' ').split.map(&:capitalize).join(' ')
  end
end

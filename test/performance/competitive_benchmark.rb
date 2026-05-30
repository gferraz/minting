require 'test_helper'
require 'benchmark'
require 'benchmark/ips'
require 'money'
require 'bigdecimal'

using Mint

class CompetitiveBenchmark < Minitest::Test
  def setup
    # Configure Money gem for fair comparison
    require_relative 'competitive_performance_benchmark'
    require_relative 'competitive_memory_benchmark'
    # Calculate differences
    mint_diff = after_mint.merge(before_mint) do |_key, after_val, before_val|
      after_val - before_val
    end
    money_diff = after_money.merge(before_money) do |_key, after_val, before_val|
      after_val - before_val
    end

    # Show significant allocations
    significant_types = (mint_diff.keys + money_diff.keys).uniq.select do |k|
      (mint_diff[k] || 0) > 10 || (money_diff[k] || 0) > 10
    end

    significant_types.each do |type|
      mint_alloc = mint_diff[type] || 0
      money_alloc = money_diff[type] || 0
      puts "  #{type}:"
      puts "    Mint: #{mint_alloc}"
      puts "    Money: #{money_alloc}"
      puts "    Ratio: #{money_alloc.zero? ? 'N/A' : (mint_alloc.to_f / money_alloc).round(2)}x"
    end
  end
end

# Helper method for string formatting
class String
  def humanize
    tr('_', ' ').split.map(&:capitalize).join(' ')
  end
end

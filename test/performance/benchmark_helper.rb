require_relative '../test_helper'
require 'benchmark'
require 'benchmark/ips'
require 'bigdecimal'
require 'money'

using Mint

module BenchmarkHelper
  def configure_money_gem(rounding: BigDecimal::ROUND_HALF_UP, currency: 'USD')
    Money.rounding_mode = rounding
    Money.default_currency = Money::Currency.new(currency)
  end

  def test_amounts
    @test_amounts ||= [1.00, 10.50, 123.45, 999.99, 1234.56]
  end

  def random_amounts(size: 1000, range: -1000.00..1000.00)
    @random_amounts ||= Array.new(size) { rand(range) }
  end

  module_function :configure_money_gem, :test_amounts, :random_amounts
end

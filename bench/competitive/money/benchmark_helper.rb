# frozen_string_literal: true

require 'bigdecimal'
require 'money'

Money.rounding_mode = BigDecimal::ROUND_HALF_UP
Money.default_currency = Money::Currency.new('USD')

require_relative '../../benchmark_helper'

module MoneyBenchHelper
  def configure_money_gem(rounding: BigDecimal::ROUND_HALF_UP, currency: 'USD')
    Money.rounding_mode = rounding
    Money.default_currency = Money::Currency.new(currency)
  end
end

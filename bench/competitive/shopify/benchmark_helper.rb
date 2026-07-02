# frozen_string_literal: true

require 'bigdecimal'
require 'shopify-money'

Money.default_currency = Money::Currency.new('USD')

require_relative '../../benchmark_helper'

module ShopifyBenchHelper
  def configure_shopify_money_gem(currency: 'USD')
    Money.default_currency = Money::Currency.new(currency)
  end
end

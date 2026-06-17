# frozen_string_literal: true

require 'money'

module ShopifyBenchHelper
  def configure_shopify_money_gem(currency: 'USD')
    Money.default_currency = Money::Currency.new(currency)
    Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
    Money.locale_backend = :currency
  end
end

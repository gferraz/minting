# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'
require 'erb'

module Mint
  # :nodoc:
  class Money
    # Converts the monetary amount to a BigDecimal object.
    #
    # @return [BigDecimal] the decimal representation of the money amount
    # @example
    #   Money.from(9.99, 'USD').to_d  #=> 0.999e1
    def to_d = amount.to_d 0

    # Converts the monetary amount to a standard float.
    # Note: Using float conversion loses precision guarantees.
    #
    # @return [Float] the floating-point representation of the money amount
    def to_f = amount.to_f

    # Renders a safe HTML5 `<data>` element containing the formatted currency.
    # Embeds the ISO currency description and raw value as the metadata `title` attribute.
    #
    # @param format [String] the display format to apply to the visible HTML text
    # @return [String] HTML5 `<data>` representation
    def to_html(format = DEFAULT_FORMAT)
      title = Kernel.format("#{currency_code} %0.#{currency.subunit}f", amount)
      body = format(format)
      %(<data class='money' title='#{title}'>#{ERB::Util.html_escape(body)}</data>)
    end

    # Returns a Hash representation of the money instance.
    #
    # @return [Hash] hash with :currency (String) and :amount (String) keys
    # @example
    #   Money.from(134120, 'BRL').to_hash
    #   #=> { currency: "BRL", amount: "134120.00" }
    def to_hash
      { currency: currency_code, amount: Kernel.format("%0.#{currency.subunit}f", amount) }
    end

    # Deserializes a Hash into a Money instance.
    #
    # Accepts both symbol and string keys, matching the output of {#to_hash}.
    #
    # @param hash [Hash] a hash with +:currency+ (or +"currency"+) and
    #   +:amount+ (or +"amount"+) keys
    # @return [Money] the deserialized Money instance
    # @raise [Mint::UnknownCurrency] if the currency can't be resolved
    # @raise [ArgumentError] if amount is not parseable as a Rational
    #
    # @example
    #   Money.from_hash(currency: "USD", amount: "9.99")
    #   #=> [USD 9.99]
    # @example Round-trip
    #   m = Money.from(134120, "BRL")
    #   Money.from_hash(m.to_hash) == m  #=> true
    def self.from_hash(hash)
      currency = Currency.resolve!(hash[:currency] || hash['currency'])
      amount = currency.normalize_amount(Rational(hash[:amount] || hash['amount']))
      amount.zero? ? currency.zero : new(amount, currency)
    end

    # Returns the exact internal Rational representation of the monetary amount.
    #
    # @return [Rational] the rational representation of the money amount
    def to_r = amount
  end
end

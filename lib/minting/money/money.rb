# frozen_string_literal: true

module Mint
  class Money
    DEFAULT_FORMAT = '%<symbol>s%<amount>f'

    attr_reader :amount, :currency

    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)

      unless currency.is_a?(Currency)
        raise ArgumentError,
              'currency must be a Currency object'
      end

      @amount = amount.to_r.round(currency.subunit)
      @currency = currency
    end

    def currency_code
      currency.code
    end

    def mint(new_amount)
      new_amount.to_r == amount ? self : Money.new(new_amount, currency)
    end

    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", amount
    end

    def to_d
      @amount.to_d 0
    end

    def to_f
      amount.to_f
    end

    def to_html(format = DEFAULT_FORMAT)
      title = Kernel.format("#{currency_code} %0.#{currency.subunit}f", amount)
      %(<data class='money' title='#{title}'>#{to_s(format: format)}</data>)
    end

    def to_i
      amount.to_i
    end

    def to_json(*_args)
      subunit = currency.subunit
      Kernel.format(
        %({"currency": "#{currency_code}", "amount": "%0.#{subunit}f"}),
        amount
      )
    end

    def to_r
      @amount
    end

    def to_s(format: '%<symbol>s%<amount>f')
      format = format.gsub(/%<amount>(\+?\d*)f/,
                           "%<amount>\\1.#{currency.subunit}f")

      Kernel.format(format, amount: amount, currency: currency_code,
                            symbol: currency.symbol)
    end
  end
end

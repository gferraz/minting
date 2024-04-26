# frozen_string_literal: true

module Mint
  # Conversion logic
  class Money
    def to_d
      amount.to_d 0
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
      amount
    end

    def to_s(format: '%<symbol>s%<amount>f')
      format = format.gsub(/%<amount>(\+?\d*)f/,
                           "%<amount>\\1.#{currency.subunit}f")

      Kernel.format(format, amount: amount, currency: currency_code,
                            symbol: currency.symbol)
    end
  end
end

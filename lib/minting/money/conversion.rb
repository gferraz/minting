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

    def to_s(format: '%<symbol>s%<amount>f', delimiter: false, separator: '.')
      format = format.gsub(/%<amount>(\+?\d*)f/,
                           "%<amount>\\1.#{currency.subunit}f")
      formatted = Kernel.format(format, amount: amount, currency: currency_code,
                                        symbol: currency.symbol)
      if delimiter
        # Thanks Money gem for the regular expression
        formatted.gsub!(/(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/, "\\1#{delimiter}")
      end
      formatted.tr!('.', separator) if separator != '.'
      formatted
    end
  end
end

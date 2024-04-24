module Mint
  class Money
    attr_reader :amount, :currency

    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Numeric' unless amount.is_a?(Numeric)
      raise ArgumentError, 'currency must be a Currency object' unless currency.is_a?(Currency)

      @amount = amount.to_r.round(currency.subunit)
      @currency = currency
    end

    def currency_code
      @currency.code
    end

    def mint(new_amount)
      new_amount.to_r == amount ? self : Money.new(new_amount, currency)
    end

    def format(format: '')
      format = format.blank? ? '%<symbol>s%<amount>f' : format.dup
      format.gsub!(/%<amount>(\+?\d*)f/, "%<amount>\\1.#{subunit}f")

      Kernel.format(format, amount: amount, currency: code, symbol: symbol)
    end

    def inspect
      Kernel.format "[#{currency_code} %0.#{currency.subunit}f]", @amount
    end

    def to_d
      @amount.to_d 0
    end

    def to_f
      @amount.to_f
    end

    def to_html(format = '')
      title = Kernel.format("#{currency_code} %0.#{currency.subunit}f", amount)
      content = currency.format(@amount, format: format)
      %(<data class='money' title='#{title}'>#{content}</data>)
    end

    def to_i
      @amount.to_i
    end

    def to_json(*_args)
      Kernel.format %({"currency": "#{currency_code}", "amount": "%0.#{currency.subunit}f"}), @amount
    end

    def to_r
      @amount
    end

    def to_s(format: '')
      currency.format(@amount, format: format)
    end
  end
end

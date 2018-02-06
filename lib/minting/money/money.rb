
class Mint
  class Money
    attr_reader :amount
    attr_reader :currency

    def initialize(amount, currency)
      raise ArgumentError, 'amount must be Rational'            unless amount.is_a?(Rational)
      raise ArgumentError, 'currency must be a Currency object' unless currency.is_a?(Currency)
      @amount = amount.round(currency.subunit)
      @currency = currency
    end

    def currency_code
      @currency.code
    end

    def mint(amount)
      Money.new(amount, currency)
    end

    def inspect
      format "[#{currency_code} %0.#{currency.subunit}f]", @amount
    end

    def to_d
      @amount.to_d(0)
    end

    def to_f
      @amount.to_f
    end

    def to_i
      @amount.to_i
    end

    def to_json
      format %({"currency": "#{currency_code}", "amount": "%0.#{currency.subunit}f"}), @amount
    end

    def to_r
      @amount
    end

    def to_s(format: '')
      currency.format(@amount, format: format)
    end
  end
end

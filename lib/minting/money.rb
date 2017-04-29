
class Money
  include Comparable

  attr_reader :currency

  def initialize(amount, currency)
    raise ArgumentError, 'amount must be Rational'            unless amount.is_a?(Rational)
    raise ArgumentError, 'currency must be a Currency object' unless currency.is_a?(Currency)
    @amount = amount.round(currency.subunit, half: :up) # TODO: review what wounding configuration to use
    @currency = currency
  end

  def to_r
    @amount
  end

  def zero?
    @amount.zero?
  end

  # @return true if both are zero, or both have same amount and same currency
  def ==(other)
    @amount.zero? && other.respond_to?(:zero?) && other.zero? ||
      @amount == other.to_r && @currency == other.currency
  end
end

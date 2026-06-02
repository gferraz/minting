require 'erb'

module Mint
  # Conversion and serialization logic for {Money} instances.
  class Money
    # Converts the monetary amount to a {BigDecimal} object.
    #
    # @return [BigDecimal] the decimal representation of the money amount
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
      body = to_s(format: format)
      %(<data class='money' title='#{title}'>#{ERB::Util.html_escape(body)}</data>)
    end

    # Truncates and converts the monetary amount to an Integer.
    #
    # @return [Integer] the integer representation of the money amount
    def to_i = amount.to_i

    def to_hash
      { currency: currency_code, amount: Kernel.format("%0.#{currency.subunit}f", amount) }
    end

    # Serializes the money instance to a standard JSON object containing the amount and currency.
    # Highly optimized to run without external dependencies.
    #
    # @return [String] the JSON serialized string representation
    def to_json(*_args)
      Kernel.format(
        %({"currency": "#{currency_code}", "amount": "%0.#{currency.subunit}f"}), amount
      )
    end

    # Returns the exact internal Rational representation of the monetary amount.
    #
    # @return [Rational] the rational representation of the money amount
    def to_r = amount
  end
end

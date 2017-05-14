
class FormatterTest < Minitest::Test
  def test_formatter_constructor
    some_dollars = Mint.new(:USD).money(1.23)

    simple_formatter = Mint::Formatter.new do |money, options|
      "[#{options.symbol}#{money.to_s(format: '%<amount>f')}]"
    end
    assert_equal '[US$1¢23]', simple_formatter.format(some_dollars, symbol: 'US$', separator: '¢')

    numeric_formatter = Mint::Formatter.new { |money| money.to_s(format: '%<amount>f') }
    assert_equal '1.23', numeric_formatter.format(some_dollars)
  end
end

class FormatterTest < Minitest::Test
  def test_formatter_constructor
    some_dollars = Mint.new(:USD).money(1.23)

    numeric_formatter = Mint::Formatter.new { |money| money.to_s(format: '%<amount>f') }
    assert_equal '1.23', numeric_formatter.format(money: some_dollars)

    formatter = Mint::Formatter.new do |money, options|
      "#{options.symbol}#{numeric_formatter.format(money: money)}".tr!('.', options.separator)
    end

    assert_equal 'US$1¢23', formatter.format(money: some_dollars, symbol: 'US$', separator: '¢')
  end

  def test_formatter_registration
    assert Mint::Formatter.register(:numeric) { |money| money.to_s(format: '%<amount>f') }
    assert_raises IndexError, 'numeric formatter already exists' do
      Mint::Formatter.register!(:numeric) {}
    end

    # assert_equal '1.23', Mint.format(some_dollars, :numeric)
  end
end

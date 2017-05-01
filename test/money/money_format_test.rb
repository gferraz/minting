class MoneyFormatTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_numeric_conversion
    money = Mint::Money.new(999 / 100r, USD)

    assert_equal '$9.99',    money.to_s
    assert_equal '9',        money.to_s(format: '%<amount>d')
    assert_equal '$9.99',    money.to_s(format: '%<symbol>s%<amount>0.2f')
    assert_equal '9.99',     money.to_s(format: '%<amount>0.2f')
    assert_equal '9.99 USD', money.to_s(format: '%<amount>0.2f %<currency>s')
    assert_equal '$+9.99',   money.to_s(format: '%<symbol>s%<amount>+0.2f')

    assert_equal '-9.99',    (-money).to_s(format: '%<amount>0.2f')
  end
end

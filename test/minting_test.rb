require 'test_helper'

class MintingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minting::VERSION
  end

  def test_usage
    usd = Mint.new(:USD)
    eur = Mint.new(:EUR)

    # 10.00 USD
    money = usd.money(10)
    assert_equal 10, money.to_i # 10
    assert_equal 'USD', money.currency_code

    # Comparisons
    assert_equal usd.money(10), usd.money(10) # true
    refute_equal usd.money(10), usd.money(1)  # false
    refute_equal usd.money(10), eur.money(10) # false
    refute_equal usd.money(10), eur.money(10) # true
  end
end

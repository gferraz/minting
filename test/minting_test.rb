require 'test_helper'

class MintingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minting::VERSION
  end

  def test_readme_usage
    usd = Mint.new(:USD)

    ten_dollars = usd.money(10)
    assert_equal 10, ten_dollars.to_i
    assert_equal 'USD', ten_dollars.currency_code

    assert_equal ten_dollars, usd.money(10)
    refute_equal ten_dollars, usd.money(1)
    refute_equal ten_dollars, Mint.money(10, :EUR)
    refute_equal ten_dollars, Mint.money(10, :EUR)
  end
end

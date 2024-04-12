class MintingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minting::VERSION
  end

  def test_readme_usage
    ten_dollars = Mint.money(10, 'USD')

    assert_equal 10, ten_dollars.to_i
    assert_equal 'USD', ten_dollars.currency_code

    # Comparisons

    assert_equal ten_dollars, Mint.money(10, 'USD')
    refute_equal ten_dollars, Mint.money(1, 'USD')
    refute_equal ten_dollars, Mint.money(10, 'EUR')

    assert ten_dollars.eql? Mint.money(10, 'USD')
    assert_equal ten_dollars.hash, Mint.money(10, 'USD').hash

    # Format (uses Kernel.format internally)
    price = Mint.money(9.99, 'USD')

    price.to_s
    price.to_s(format: '%<amount>d')            #=> "9",
    price.to_s(format: '%<symbol>s%<amount>f')  #=> "$9.99",
    price.to_s(format: '%<symbol>s%<amount>+f') #=> "$+9.99",
    (-price).to_s(format: '%<amount>f')         #=> "-9.99",

    # Format with padding
    price_in_euros = Mint.money(12.34, 'EUR')

    price.to_s(format: '--%<amount>7d')               #=> "--      9"
    price.to_s(format: '  %<amount>10f %<currency>s') #=> "        9.99 USD"
    (-price).to_s(format: '  %<amount>10f')           #=> "       -9.99"

    price_in_euros.to_s(format: '%<symbol>2s%<amount>+10f') #=> " €    +12.34"

    # Json serialization

    price.to_json # "{"currency": "USD", "amount": "9.99"}

    # Allocation and split

    ten_dollars.split(3) #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
    ten_dollars.split(7) #=> [[USD 1.42], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43]]

    ten_dollars.allocate([1, 2, 3]) #=> [[USD 1.67], [USD 3.33], [USD 5.00]]
  end
end

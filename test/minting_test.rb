class MintingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minting::VERSION
  end

  def test_readme_usage # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Minitest/MultipleAssertions
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

    assert_equal '$9.99',  price.to_s
    assert_equal '9',      price.to_s(format: '%<amount>d')
    assert_equal '$9.99',  price.to_s(format: '%<symbol>s%<amount>f')
    assert_equal '$+9.99', price.to_s(format: '%<symbol>s%<amount>+f')
    assert_equal '-9.99',  (-price).to_s(format: '%<amount>f')

    # Format with padding
    price_in_euros = Mint.money(12.34, 'EUR')

    assert_equal '--      9',        price.to_s(format: '--%<amount>7d')
    assert_equal '        9.99 USD', price.to_s(format: '  %<amount>10f %<currency>s')
    assert_equal '       -9.99',     (-price).to_s(format: '  %<amount>10f')

    assert_equal ' €    +12.34',
                 price_in_euros.to_s(format: '%<symbol>2s%<amount>+10f')

    # Json serialization

    assert_equal '{"currency": "USD", "amount": "9.99"}', price.to_json

    # Hash conversion
    assert_equal({ currency: 'USD', amount: '9.99' }, price.to_hash)

    # Fractional units (inverse of #fractional)
    assert_equal 999, price.fractional
    assert_equal Mint.money(9.99, 'USD'),
                 Mint::Money.from_fractional(999, 'USD')
    assert_equal Mint.money(1234, 'JPY'),
                 Mint::Money.from_fractional(1234, 'JPY')

    # Allocation and split

    assert_equal(
      [3.34, 3.33, 3.33].map { |a| Mint.money(a, 'USD') },
      ten_dollars.split(3)
    )

    assert_equal(
      [1.42, 1.43, 1.43, 1.43, 1.43, 1.43, 1.43].map { |a| Mint.money(a, 'USD') },
      ten_dollars.split(7)
    )

    assert_equal(
      [1.67, 3.33, 5.00].map { |a| Mint.money(a, 'USD') },
      ten_dollars.allocate([1, 2, 3])
    )
  end
end

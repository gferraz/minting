# frozen_string_literal: true

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

    assert_equal '$9.99',  price.to_s
    assert_equal '9',      price.to_formatted_s(format: '%<amount>d')
    assert_equal '$ 9', price.to_formatted_s(format: '%<symbol>s%<amount> d')
    assert_equal '$-9.99',  (-price).to_formatted_s(format: '%<symbol>s%<amount> f')
    assert_equal '$ 9.99',  price.to_formatted_s(format: '%<symbol>s%<amount> f')
    assert_equal '$9.99',  price.to_formatted_s(format: '%<symbol>s%<amount>f')
    assert_equal '$+9.99', price.to_formatted_s(format: '%<symbol>s%<amount>+f')
    assert_equal ' 9.99',  price.to_formatted_s(format: '%<amount> f')
    assert_equal '-9.99',  (-price).to_formatted_s(format: '%<amount> f')
    assert_equal '-9.99 USD', (-price).to_formatted_s(format: '%<amount> f %<currency>s')

    # Format with padding
    price_in_euros = Mint.money(12.34, 'EUR')

    assert_equal '--      9',        price.to_formatted_s(format: '--%<amount>7d')
    assert_equal '        9.99 USD', price.to_formatted_s(format: '  %<amount>10f %<currency>s')
    assert_equal '       -9.99',     (-price).to_formatted_s(format: '  %<amount>10f')

    assert_equal ' €    +12.34',
                 price_in_euros.to_formatted_s(format: '%<symbol>2s%<amount>+10f')

    # Per-sign Hash format (accounting parentheses, zero placeholder)
    loss = Mint.money(-1234.56, 'USD')

    assert_equal '($1,234.56)',
                 loss.to_formatted_s(format: { negative: '(%<symbol>s%<amount>f)' })

    assert_equal '--',
                 Mint.money(0, 'BRL').to_formatted_s(format: { zero: '--' })

    fmt = {
      positive: '%<symbol>s%<amount>f',
      negative: '(%<symbol>s%<amount>f)',
      zero: '--'
    }

    assert_equal '$1,234.56', Mint.money(1234.56, 'USD').to_formatted_s(format: fmt)

    # Json serialization

    assert_equal '{"currency": "USD", "amount": "9.99"}', price.to_json

    # Hash conversion
    assert_equal({ currency: 'USD', amount: '9.99' }, price.to_hash)

    # Fractional units (inverse of #fractional)
    assert_equal 999, price.subunits
    assert_equal Mint.money(9.99, 'USD'),
                 Mint::Money.from_subunits(999, 'USD')
    assert_equal Mint.money(1234, 'JPY'),
                 Mint::Money.from_subunits(1234, 'JPY')

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

    # Clamping to a range

    price = 50.dollars

    assert_equal 50.dollars, price.clamp(0, 100)
    assert_equal 25.dollars, price.clamp(0, 25)
    assert_equal 75.dollars, price.clamp(75, 100)

    # Clamp accepts Money bounds or Numeric amounts
    assert_equal 75.dollars, price.clamp(75.dollars, 100.dollars) #=> [USD 75.00]
  end
end

# frozen_string_literal: true

class CryptoTest < Minitest::Test
  REGISTERED_AT = Mint::Registry.register_crypto('BTC', 'ETH', 'USDT', 'SOL', 'XRP', 'DOGE', 'ADA', 'LTC')

  def setup
    @crypto = Mint::Registry.crypto_currencies
    @btc = @crypto.find { |c| c.code == 'BTC' }
    @eth = @crypto.find { |c| c.code == 'ETH' }
    @usdt = @crypto.find { |c| c.code == 'USDT' }
    nil
  end

  def test_crypto_currencies_returns_frozen_array
    assert_predicate @crypto, :frozen?
    assert_kind_of Array, @crypto
    assert_operator @crypto.size, :>=, 20
  end

  def test_btc_is_first
    assert_equal 'BTC', @crypto[0].code
  end

  def test_btc_attributes
    assert_equal 'BTC', @btc.code
    assert_equal 8, @btc.subunit
    assert_equal '₿', @btc.symbol
    assert_equal 1000, @btc.priority
    assert_equal 'Bitcoin', @btc.name
    assert_equal 100_000_000, @btc.fractional_multiplier
  end

  def test_eth_attributes
    assert_equal 18, @eth.subunit
    assert_equal 'Ξ', @eth.symbol
    assert_equal 950, @eth.priority
  end

  def test_usdt_attributes
    assert_equal 6, @usdt.subunit
    assert_equal '$', @usdt.symbol
    assert_equal 900, @usdt.priority
  end

  def test_register_crypto_raises_on_duplicate
    assert_raises(KeyError) { Mint::Registry.register_crypto('BTC') }
  end

  def test_register_crypto_raises_on_unknown_code
    assert_raises(ArgumentError) { Mint::Registry.register_crypto('NOPE') }
  end

  def test_register_crypto_raises_on_mixed_unknown
    assert_raises(ArgumentError) { Mint::Registry.register_crypto('BTC', 'NOPE', 'ETH') }
  end

  def test_registered_crypto_works_with_money
    btc = Mint.money(1, 'BTC')

    assert_equal 1, btc.amount
    assert_equal 'BTC', btc.currency_code
    assert_kind_of Mint::Money, btc
  end

  def test_registered_crypto_formats
    btc = Mint.money(0.01, 'BTC')

    assert_match('₿0.01000000', btc.to_s)
  end

  def test_registered_crypto_arithmetics
    a = Mint.money(1, 'BTC')
    b = Mint.money(2, 'BTC')

    assert_equal Mint.money(3, 'BTC'), a + b
  end

  def test_crypto_priority_in_parser
    parsed = Mint.parse('$100')

    assert_equal 'USD', parsed.currency_code
  end

  def test_currency_crypto_currencies_delegates
    assert_same Mint::Registry.crypto_currencies, Money::Currency.crypto_currencies
  end

  def test_currency_register_crypto_delegates
    assert_raises(KeyError) { Money::Currency.register_crypto('BTC') }
  end

  def test_currency_register_all_crypto_delegates
    assert_raises(KeyError) { Money::Currency.register_all_crypto }
  end

  def test_crypto_code_detection_in_parser
    parsed = Mint.parse('0.01 BTC')

    assert_equal 'BTC', parsed.currency_code
    assert_equal Rational(1, 100), parsed.amount
  end

  def test_register_all_crypto_raises_on_conflict
    assert_raises(KeyError) { Mint::Registry.register_all_crypto }
  end

  def test_register_all_crypto_registers_new_codes
    # start fresh: only know BCH isn't registered yet
    refute Mint::Registry.currencies.key?('BCH')
    Mint::Registry.register_crypto('BCH')

    assert Mint::Registry.currencies.key?('BCH')
  end
end

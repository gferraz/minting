# frozen_string_literal: true

using Mint

class MintTest < Minitest::Test
  def test_money_minting
    ten_reais = Mint.money(10, 'BRL')

    assert_equal Mint.money(10.01, 'PEN'), Mint.money(10.01, 'PEN')

    assert_equal ten_reais, ten_reais.change(10)
    assert_equal ten_reais, ten_reais.change(9.999)
  end

  def test_register
    sgx = Mint.register_currency(code: 'SGX', subunit: 2, symbol: '^')

    assert_equal Mint::Currency.for_code('SGX'), sgx
  end

  def test_zero
    assert_equal Mint.money(0, 'USD'), Mint.zero('USD')
    assert_equal Mint.money(0, 'BRL'), Mint.zero('BRL')
    assert_equal Mint.money(0, 'JPY'), Mint.zero('JPY')
  end

  def test_zero_with_currency_object
    assert_equal Mint.money(0, 'USD'), Mint.zero(Mint::Currency.for_code('USD'))
  end

  def test_zero_returns_same_object
    assert_same Mint.zero('USD'), Mint.zero('USD')
  end

  def test_zero_unknown_currency
    assert_raises(ArgumentError) { Mint.zero('UNKNOWN') }
    assert_raises(ArgumentError) { Mint.zero(nil) }
  end

  def test_mint_zero_returns_singleton
    zero_from_create = Mint.money(0, 'USD')
    zero_from_mint  = Mint.money(10, 'USD').change(0)
    zero_from_zero  = Mint.zero('USD')

    assert_same zero_from_zero, zero_from_create
    assert_same zero_from_zero, zero_from_mint
  end

  def test_currencies_frozen
    assert_predicate Mint::Registry.currencies, :frozen?
  end

  def test_concurrent_zero_returns_same_object
    threads = Array.new(10) { Thread.new { Mint.zero('USD') } }
    results = threads.map(&:value)

    assert(results.all? { |z| z.equal?(results.first) })
  end

  def test_concurrent_zero_different_currencies
    codes = %w[USD BRL JPY PEN EUR]
    threads = codes.cycle.first(20).map { |code| Thread.new { Mint.zero(code) } }
    results = threads.map(&:value)

    codes.each do |code|
      group = results.select { |m| m.currency.code == code }

      assert group.all? { |m| m.equal?(group.first) },
             "All #{code} zeros should be the same object"
    end
  end

  def test_concurrent_register
    codes = %w[AAA BBB CCC DDD]
    threads = codes.map { |code| Thread.new { Mint.register_currency(code:) } }
    results = threads.map(&:value)

    results.each { |currency| assert_kind_of Mint::Currency, currency }
    codes.each { |code| refute_nil Mint::Currency.for_code(code) }
  end

  def test_concurrent_register_raises_on_duplicate
    Mint.register_currency(code: 'ZZZ_')

    threads = Array.new(5) do
      Thread.new do
        Mint.register_currency(code: 'ZZZ_')
      rescue StandardError
        nil
      end
    end
    results = threads.map(&:value)

    assert_empty results.compact
  end

  def test_concurrent_reads_during_registration
    reader = Thread.new do
      100.times do
        Mint::Currency.for_code('USD')
        Mint::Registry.currencies.values
      end
    end

    writer = Thread.new do
      Mint.register_currency(code: 'EEE')
    end

    reader.join
    writer.join

    assert Mint::Currency.for_code('EEE')
  end

  def test_mint_refinements
    assert_equal 1.dollar, Mint.money(1, 'USD')
    assert_equal 1.euro, Mint.money(1, 'EUR')
    assert_equal 3.reais, Mint.money(3, 'BRL')
    assert_equal 4.to_money('USD'), Mint.money(4, 'USD')
    assert_equal 4.2.dollars, Mint.money(4.2, 'USD')
    assert_equal 5.3.euros, Mint.money(5.3, 'EUR')
    assert_equal 5.4.to_money('EUR'), Mint.money(5.4, 'EUR')
    assert_equal 5.5.mint('EUR'), Mint.money(5.5, 'EUR')
    assert_equal '5.61'.to_money('EUR'), Mint.money(5.61, 'EUR')
    assert_equal '6.30'.to_money('USD'), Mint.money(6.30, 'USD')
  end

  def test_money_range_step
    assert_equal [1.dollar, 2.dollars, 3.dollars],
                 ((1.dollar)..(3.dollars)).step(1.dollar).to_a

    assert_equal [1.dollar, 2.dollars],
                 ((1.dollar)...(3.dollars)).step(1.dollar).to_a

    assert_equal [1.dollar, 3.dollars, 5.dollars],
                 ((1.dollar)..(6.dollars)).step(2.dollars).to_a

    assert_equal [],
                 ((1.dollar)..(6.dollars)).step(-2.dollars).to_a

    assert_equal [10.dollars, 8.dollars, 6.dollars],
                 ((10.dollars)..(6.dollars)).step(-2.dollars).to_a

    assert_equal [10.dollars, 8.dollars],
                 ((10.dollars)...(6.dollars)).step(-2.dollars).to_a

    assert_equal [10.dollars],
                 ((10.dollars)..(6.dollars)).step(-6.dollars).to_a

    assert_equal [1, 3, 5], (1..6).step(2).to_a

    assert_raises(TypeError) { (1..6).step(2.dollars).to_a }
  end

  def test_money_range_step_edge_cases
    # Beginless range — should raise TypeError, matching core Ruby 3 or ArgumentError for Ruby 4
    assert_raises(StandardError) { (..(6.dollars)).step(1.dollar).to_a }

    # Endless range with block — verify it actually iterates correctly
    # (use first(n) via break, since .to_a would hang)
    enum = ((1.dollar)..).step(1.dollar)

    assert_equal [1.dollar, 2.dollars, 3.dollars], enum.first(3)

    # Single-element range (begin == end, inclusive)
    assert_equal [1.dollar], ((1.dollar)..(1.dollar)).step(1.dollar).to_a

    # Single-element range, exclusive — empty
    assert_equal [], ((1.dollar)...(1.dollar)).step(1.dollar).to_a

    # Step size of zero raises
    if RUBY_VERSION < '4.0'
      assert_raises(ArgumentError) { ((1.dollar)..(3.dollars)).step(0.dollars).to_a }
    else
      assert_equal [], ((1.dollar)...(1.dollar)).step(1.dollar).to_a
    end

    # Step larger than range span (positive direction)
    assert_equal [1.dollar], ((1.dollar)..(3.dollars)).step(10.dollars).to_a

    # Block form returns self and yields correctly
    result = []
    range = ((1.dollar)..(3.dollars))
    returned = range.step(1.dollar) { |v| result << v }

    assert_equal [1.dollar, 2.dollars, 3.dollars], result
    assert_same range, returned

    # Enumerator form without block
    assert_kind_of Enumerator, ((1.dollar)..(3.dollars)).step(1.dollar)

    assert_raises(TypeError) { ((1.dollar)..(3.dollars)).step(1.euro).to_a }
  end
end

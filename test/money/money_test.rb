# frozen_string_literal: true

using Mint

class MoneyTest < Minitest::Test
  def test_its_contructors
    assert_instance_of Mint::Money, Mint.money(100, 'USD')
    assert_predicate Mint.money(100, 'USD'), :frozen?

    assert_raises(ArgumentError) { Mint.money('b', 'USD') }
    assert_raises(ArgumentError) { Mint.money(10r, Object.new) }
    assert_raises(ArgumentError) { Mint.money(1, 'NOT_A_CURRENCY') }
  end

  def test_amount
    assert_equal 100, Mint.money(100, 'USD').amount
    assert_equal 1,   Mint.money(1, 'USD').amount
    assert_equal 14,  Mint.money(14, Mint.currency('PEN')).amount
  end

  def test_hash
    assert_equal Mint.money(2, 'USD').hash, Mint.money(2, 'USD').hash
    refute_equal Mint.money(2, 'USD').hash, Mint.money(0, 'USD').hash
    refute_equal Mint.money(2, 'USD').hash, Mint.money(2, 'BRL').hash
  end

  def test_inspect
    assert_equal '[USD 10.34]', Mint.money(10.34, 'USD').inspect
  end

  def test_same_currency
    assert 10.34.mint('USD').same_currency?(Mint.money(100, 'USD'))
    refute 10.34.mint('USD').same_currency?(30)
    refute 10.34.mint('USD').same_currency?(Mint.money(10.34, 'BRL'))
  end

  def test_zero
    zero = Mint.zero
    zero_soles = Mint.money(0r, Mint.currency('PEN'))

    assert_predicate 0.dollars, :zero?
    assert_equal 0.dollars, zero_soles
    assert_equal 0, 0.dollars
    assert_equal 0, 0.dollars
    assert_equal zero, 0.dollars
    refute_predicate Mint.money(100r, 'USD'), :zero?
  end

  def test_nonzero
    two_soles = Mint.money(2, Mint.currency('PEN'))

    assert_predicate 2.dollars, :nonzero?
    refute_equal 2.dollars, two_soles
    refute_equal 0, 2.dollars
    refute_equal 2.dollars, 0
  end

  def test_creation
    assert Mint::Money.new(3, Mint.currency('PEN'))
    assert_raises(ArgumentError) { Mint::Money.create('334.2', Mint.currency('PEN')) }
    assert_raises(ArgumentError) { Mint::Money.create(3, Object.new) }
  end

  def test_fractional
    assert_equal 123_456, Mint.money(1234.56, 'USD').fractional
    assert_equal 123_00, Mint.money(123, 'USD').fractional
    assert_equal 123_99, Mint.money(123.9912, 'USD').fractional
  end

  def test_from_fractional
    # Subunit 2: USD cents
    assert_equal Mint.money(1234.56, 'USD'),
                 Mint::Money.from_fractional(123_456, 'USD')
    assert_equal Mint.money(0, 'USD'),
                 Mint::Money.from_fractional(0, 'USD')
    assert_equal Mint.money(0.01, 'USD'),
                 Mint::Money.from_fractional(1, 'USD')

    # Subunit 0: JPY yen (multiplier == 1)
    assert_equal Mint.money(1234, 'JPY'),
                 Mint::Money.from_fractional(1234, 'JPY')
    assert_equal Mint.money(0, 'JPY'),
                 Mint::Money.from_fractional(0, 'JPY')

    # Subunit 3: IQD fils (multiplier == 1000)
    assert_equal Mint.money(123.456, 'IQD'),
                 Mint::Money.from_fractional(123_456, 'IQD')

    # Accepts Symbol and Currency
    assert_equal Mint.money(1, 'USD'),
                 Mint::Money.from_fractional(100, 'USD')
    assert_equal Mint.money(1, 'USD'),
                 Mint::Money.from_fractional(100, Mint.currency('USD'))
  end

  def test_from_fractional_round_trip
    [9.99, 100, 0, 0.01, 1_234_567.89].each do |amount|
      m = Mint.money(amount, 'USD')

      assert_equal m, Mint::Money.from_fractional(m.fractional, 'USD'),
                   "round trip failed for #{amount}"
    end
  end

  def test_from_fractional_rejects_non_integer
    assert_raises(ArgumentError) { Mint::Money.from_fractional(1.5, 'USD') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional('100', 'USD') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100r, 'USD') }
  end

  def test_from_fractional_rejects_unknown_currency
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100, 'ZZZ') }
    assert_raises(ArgumentError) { Mint::Money.from_fractional(100, Object.new) }
  end
end

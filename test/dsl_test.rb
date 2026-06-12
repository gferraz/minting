# frozen_string_literal: true

class DslTest < Minitest::Test
  def setup
    @original_money_defined = Object.const_defined?(:Money)
    @original_currency_defined = Object.const_defined?(:Currency)
    @original_money    = Object.const_get(:Money)    if @original_money_defined
    @original_currency = Object.const_get(:Currency) if @original_currency_defined
  end

  def teardown
    restore_const(:Money, @original_money_defined, @original_money)
    restore_const(:Currency, @original_currency_defined, @original_currency)
  end

  def test_defines_top_level_aliases_when_missing
    remove_const(:Money)
    remove_const(:Currency)

    Mint.use_top_level_constants!

    assert_equal Mint::Money, Money
    assert_equal Mint::Currency, Currency
  end

  def test_does_not_override_existing_money
    Object.const_set(:Money, :existing_money)
    Object.const_set(:Currency, :existing_currency)

    assert_raises(NameError) { Mint.use_top_level_constants! }
    assert_equal :existing_money, Money
    assert_equal :existing_currency, Currency
  end

  def test_does_not_override_already_defined_money
    Object.const_set(:Money, Mint::Money)
    Object.const_set(:Currency, Mint::Currency)

    assert_output('', /already defined/) { Mint.use_top_level_constants! }

    assert_equal Mint::Money, Money
    assert_equal Mint::Currency, Currency
  end

  private

  def remove_const(name)
    Object.send(:remove_const, name) if Object.const_defined?(name)
  end

  def restore_const(name, was_defined, value)
    remove_const(name)
    Object.const_set(name, value) if was_defined
  end
end

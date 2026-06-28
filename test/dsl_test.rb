# frozen_string_literal: true

class DslTest < Minitest::Test
  def setup
    @original_money_defined = Object.const_defined?(:Money)
    @original_money = Object.const_get(:Money) if @original_money_defined
    @original_currency_defined = Object.const_defined?(:Currency)
    @original_currency = Object.const_get(:Currency) if @original_currency_defined
  end

  def teardown
    restore_const(:Money, @original_money_defined, @original_money)
    restore_const(:Currency, @original_currency_defined, @original_currency)
  end

  def test_money_is_auto_bound_after_require
    assert Object.const_defined?(:Money), 'Money should be defined by require minting'
    assert_equal Mint::Money, Money
  end

  def test_currency_is_not_auto_bound
    refute Object.const_defined?(:Currency),
           'Currency should not be auto-bound; require minting/mint/aliases to opt in'
  end

  def test_aliases_binds_currency
    remove_const(:Currency)

    require 'minting/mint/aliases'

    assert Object.const_defined?(:Currency)
    assert_equal Mint::Currency, Currency
  end

  def test_aliases_warns_when_currency_already_defined
    remove_const(:Currency)
    Object.const_set(:Currency, :existing_currency)

    assert_output('', /already defined/) { load_aliases_file }

    assert_equal :existing_currency, Currency
  end

  private

  def remove_const(name)
    Object.send(:remove_const, name) if Object.const_defined?(name)
  end

  def restore_const(name, was_defined, value)
    remove_const(name)
    Object.const_set(name, value) if was_defined
  end

  # Re-loads aliases.rb to exercise the already-defined branch without
  # re-triggering the require guard (require returns false on second load).
  def load_aliases_file
    load File.expand_path('../lib/minting/mint/aliases.rb', __dir__)
  end
end

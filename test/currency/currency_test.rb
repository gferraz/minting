# frozen_string_literal: true

class CurrencyTest < Minitest::Test
  def setup
    @real ||= Money::Currency.for_code('BRL')
    @dollar ||= Money::Currency.for_code('USD')
    @yen ||= Money::Currency.for_code('JPY')
    nil
  end

  def test_currency_construction
    sgda = Money::Currency.new(code: 'SGDA', subunit: 2, symbol: '^')

    assert_equal sgda, Money::Currency.register(code: 'SGDA', subunit: 2, symbol: '^')

    assert_raises IndexError, 'Currency: USD already exists' do
      Money::Currency.register(code: 'USD', subunit: 2, symbol: '$')
    end

    assert_raises ArgumentError, 'Currency code must be String or Symbol' do
      Money::Currency.register(code: 'USD4', subunit: 2, symbol: '$')
    end
  end

  def test_default_currencies
    assert @real
    assert @dollar
  end

  def test_currency_accessors
    assert_equal ['BRL', 2, 'R$', 630],
                 [@real.code, @real.subunit, @real.symbol, @real.priority]
    assert_equal ['USD', 2, '$', 1000],
                 [@dollar.code, @dollar.subunit, @dollar.symbol, @dollar.priority]
  end

  def test_inspect
    assert_equal '<Currency:(BRL R$ 2 Brazilian Real)>', @real.inspect
    assert_equal '<Currency:(USD $ 2 United States Dollar)>', @dollar.inspect
  end

  def test_minimum_amount
    assert_in_delta(0.01, @dollar.minimum_amount)
    assert_in_delta(0.01, @real.minimum_amount)
    assert_equal 1, @yen.minimum_amount
  end

  def test_finder
    assert_equal 'BRL', Money::Currency.for_code('BRL').code
  end

  def test_for_symbol_returns_currency_for_unique_symbol
    brl = Money::Currency.for_symbol('R$')

    assert_instance_of Money::Currency, brl
    assert_equal 'BRL', brl.code
  end

  def test_for_symbol_returns_highest_priority_currency_for_shared_symbol
    usd = Money::Currency.for_symbol('$')

    assert_equal 'USD', usd.code
  end

  def test_for_symbol_returns_nil_for_unregistered_symbol
    assert_nil Money::Currency.for_symbol('NONE')
  end

  def test_for_symbol_returns_nil_for_empty_string
    assert_nil Money::Currency.for_symbol('')
  end

  def test_for_symbol_returns_nil_for_nil
    assert_nil Money::Currency.for_symbol(nil)
  end

  def test_registered_currencies_returns_all_registered_currencies
    all = Money::Currency.registered_currencies

    assert all.key?('USD')
    assert all.key?('BRL')
    assert all.key?('JPY')
    assert_predicate all, :frozen?
  end

  def test_resolve_bang_raises_unknown_currency_for_unregistered_code
    assert_raises(Mint::UnknownCurrency) { Money::Currency.resolve!('NOPE') }
  end

  def test_unknown_currency_inherits_from_argument_error
    assert_operator Mint::UnknownCurrency, :<, ArgumentError
  end

  def test_resolve_bang_raises_unknown_currency_for_nil
    assert_raises(Mint::UnknownCurrency) { Money::Currency.resolve!(nil) }
  end

  def test_resolve_bang_resolves_valid_code
    assert_equal @dollar, Money::Currency.resolve!('USD')
  end

  def test_resolve_accepts_object_with_to_currency
    dollar = @dollar
    obj = Object.new
    obj.define_singleton_method(:to_currency) { dollar }

    assert_equal dollar, Money::Currency.resolve(obj)
  end

  def test_resolve_accepts_object_with_currency_code
    real = @real
    obj = Object.new
    obj.define_singleton_method(:currency_code) { 'BRL' }

    assert_equal real, Money::Currency.resolve(obj)
  end

  def test_resolve_raises_on_to_currency_wrong_return_type
    obj = Object.new
    obj.define_singleton_method(:to_currency) { 'USD' }
    assert_raises(ArgumentError) { Money::Currency.resolve(obj) }
  end

  def test_resolve_raises_on_currency_code_wrong_return_type
    obj = Object.new
    obj.define_singleton_method(:currency_code) { 123 }
    assert_raises(ArgumentError) { Money::Currency.resolve(obj) }
  end

  def test_resolve_returns_nil_on_currency_code_unregistered
    obj = Object.new
    obj.define_singleton_method(:currency_code) { 'NOPE' }

    assert_nil Money::Currency.resolve(obj)
  end

  def test_resolve_bang_raises_on_currency_code_unregistered
    obj = Object.new
    obj.define_singleton_method(:currency_code) { 'NOPE' }
    assert_raises(Mint::UnknownCurrency) { Money::Currency.resolve!(obj) }
  end

  def test_resolve_bang_works_with_to_currency
    real = @real
    obj = Object.new
    obj.define_singleton_method(:to_currency) { real }

    assert_equal real, Money::Currency.resolve!(obj)
  end

  def test_resolve_to_currency_takes_precedence_over_currency_code
    dollar = @dollar
    obj = Object.new
    obj.define_singleton_method(:to_currency) { dollar }
    obj.define_singleton_method(:currency_code) { 'BRL' }

    assert_equal dollar, Money::Currency.resolve(obj)
  end

  def test_resolve_unsupported_object_still_raises
    assert_raises(ArgumentError) { Money::Currency.resolve(42) }
    assert_raises(ArgumentError) { Money::Currency.resolve(:USD) }
    assert_raises(ArgumentError) { Money::Currency.resolve([]) }
  end

  def test_resolve_existing_paths_still_work
    assert_equal @dollar, Money::Currency.resolve('USD')
    assert_equal @dollar, Money::Currency.resolve(@dollar)
    assert_equal @dollar, Money::Currency.resolve(Money.from(10, 'USD'))
    assert_nil Money::Currency.resolve(nil)
  end
end

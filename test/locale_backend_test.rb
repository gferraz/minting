# frozen_string_literal: true

class LocaleBackendTest < Minitest::Test
  def setup
    @saved_backend = Mint.locale_backend
  end

  def teardown
    Mint.locale_backend = @saved_backend
  end

  def test_defaults_to_nil
    assert_nil Mint.locale_backend
  end

  def test_accepts_a_callable
    Mint.locale_backend = -> { { decimal: ',', thousand: '.' } }

    assert_respond_to Mint.locale_backend, :call
  end

  def test_reset_to_nil
    Mint.locale_backend = -> { {} }

    Mint.locale_backend = nil

    assert_nil Mint.locale_backend
  end

  def test_to_s_uses_locale_thousands_separator
    Mint.locale_backend = -> { { thousand: '-', decimal: '|' } }
    money = Mint.money(123_456.78, 'USD')

    assert_equal '$123-456|78', money.to_s
  end

  def test_to_s_uses_locale_format_template
    Mint.locale_backend = -> { { format: '%<amount>f %<symbol>s' } }
    money = Mint.money(199.95, 'USD')

    assert_equal '199.95 $', money.to_s
  end

  def test_to_s_uses_locale_format_and_separators
    Mint.locale_backend = -> { { format: '%<amount>f %<symbol>s', decimal: ',', thousand: '.' } }

    assert_equal '1.234,56 €', Mint.money(1234.56, 'EUR').to_s
  end

  def test_explicit_decimal_overrides_backend
    Mint.locale_backend = -> { { decimal: ',' } }

    assert_equal '$99.99', Mint.money(99.99, 'USD').format(decimal: '.')
  end

  def test_explicit_thousand_overrides_backend
    Mint.locale_backend = -> { { thousand: '.' } }

    assert_equal '$1,234.56', Mint.money(1234.56, 'USD').format(thousand: ',')
  end

  def test_explicit_format_overrides_backend
    Mint.locale_backend = -> { { format: '%<symbol>s%<amount>f' } }

    assert_equal '99.95', Mint.money(99.95, 'USD').format(format: '%<amount>f')
  end

  def test_partial_locale_falls_back_to_defaults
    Mint.locale_backend = -> { { format: '%<amount>f %<symbol>s' } }

    assert_equal '99.95 $', Mint.money(99.95, 'USD').to_s
  end

  def test_non_callable_backend_is_ignored
    Mint.locale_backend = :i18n

    _, err = capture_io { Mint.money(1234.56, 'USD').to_s }

    assert_match(/invalid locale/, err)
  end


  def test_invalid_backend_is_ignored
    Mint.locale_backend = -> { 34 }

    _, err = capture_io { Mint.money(1234.56, 'USD').to_s }

    assert_match(/invalid locale/, err)
  end

  def test_backend_without_respond_to_call_is_ignored
    Mint.locale_backend = Object.new

    assert_equal '$1,234.56', Mint.money(1234.56, 'USD').to_s
  end

  def test_backend_callable_returns_fresh_values_each_time
    call_count = 0
    Mint.locale_backend = lambda {
      call_count += 1
      { decimal: ',', thousand: '.' }
    }

    3.times { Mint.money(1.23, 'USD').to_fs }

    assert_equal 3, call_count
  end

  def test_locale_backend_called_once_per_invocation
    call_count = 0
    Mint.locale_backend = lambda {
      call_count += 1
      { thousand: '-' }
    }

    5.times { Mint.money(1000, 'USD').to_s }

    assert_equal 5, call_count
  end

  def test_explicit_format_overrides_locale_format_and_separator
    Mint.locale_backend = -> { { thousand: '-', decimal: ',' } }

    assert_equal '$1-234.56', Mint.money(1234.56, 'USD').format(decimal: '.')
  end

  def test_locale_kwarg_passed_to_backend_callable
    call_count = 0
    Mint.locale_backend = lambda { |locale|
      call_count += 1
      case locale
      when :en  then { decimal: '.', thousand: ',', format: '%<symbol>s%<amount>f' }
      when :de  then { decimal: ',', thousand: '.', format: '%<amount>f %<currency>s' }
      when :br  then { decimal: ',', thousand: '.', format: '%<symbol>s%<amount>f' }
      else {}
      end
    }

    assert_equal '$1,234.56',        Mint.money(1234.56, 'USD').format(locale: :en)
    assert_equal '1.234,56 EUR',     Mint.money(1234.56, 'EUR').format(locale: :de)
    assert_equal 'R$9,99',           Mint.money(9.99, 'BRL').format(locale: :br)
    assert_equal 3, call_count
  end

  def test_locale_kwarg_indifferent_symbol_string
    called_with = nil
    Mint.locale_backend = lambda { |locale|
      called_with = locale
      {}
    }

    Mint.money(1, 'USD').format(locale: :en)

    assert_equal :en, called_with

    Mint.money(1, 'USD').format(locale: 'en')

    assert_equal 'en', called_with
  end

  def test_locale_backend_indifferent_key_access
    Mint.locale_backend = -> { { decimal: ',', thousand: '.', format: '%<amount>f %<currency>s' } }

    assert_equal '1.234,56 EUR', Mint.money(1234.56, 'EUR').to_s
  end

  def test_locale_backend_mixed_keys
    Mint.locale_backend = -> { { 'decimal' => ',', thousand: '.', format: '%<symbol>s%<amount>f' } }

    assert_equal 'R$9,99', Mint.money(9.99, 'BRL').format
  end

  def test_locale_kwarg_with_string_key
    data = {
      'en-US' => { decimal: '.', thousand: ',', format: '%<symbol>s%<amount>f' },
      'pt-BR' => { decimal: ',', thousand: '.', format: '%<symbol>s%<amount>f' }
    }
    Mint.locale_backend = ->(locale) { data[locale] || {} }

    assert_equal '$1,234.56', Mint.money(1234.56, 'USD').format(locale: 'en-US')
    assert_equal 'R$9,99',    Mint.money(9.99, 'BRL').format(locale: 'pt-BR')
  end

  def test_locale_kwarg_falls_back_to_defaults_for_unknown_locale
    Mint.locale_backend = lambda { |locale|
      { en: { decimal: ',' } }[locale] || {}
    }

    assert_equal '$9.99', Mint.money(9.99, 'USD').format(locale: :unknown)
  end

  def test_locale_kwarg_with_hash_backend_ignores_locale
    Mint.locale_backend = { decimal: ',', thousand: '.', format: '%<symbol>s%<amount>f' }

    assert_equal '$1.234,56', Mint.money(1234.56, 'USD').format(locale: :anything)
  end

  def test_arity_zero_lambda_still_works_without_locale
    call_count = 0
    Mint.locale_backend = lambda {
      call_count += 1
      { decimal: ',', thousand: '.' }
    }

    assert_equal 'R$9,99', Mint.money(9.99, 'BRL').format
    assert_equal 1, call_count
  end

  def test_i18n_key_names_separator_and_delimiter
    Mint.locale_backend = -> { { separator: ',', delimiter: '.', format: '%<amount>f %<currency>s' } }

    assert_equal '1.234,56 EUR', Mint.money(1234.56, 'EUR').to_s
  end

  def test_i18n_key_names_fallback_to_defaults
    Mint.locale_backend = -> { { separator: ',' } }

    assert_equal 'R$9,99', Mint.money(9.99, 'BRL').format
  end

  def test_mint_key_names_take_precedence_over_i18n
    Mint.locale_backend = -> { { decimal: '.', separator: ',' } }

    assert_equal '$9.99', Mint.money(9.99, 'USD').format
  end

  def test_mint_key_names_string_take_precedence_over_i18n
    Mint.locale_backend = -> { { 'decimal' => '.', separator: ',' } }

    assert_equal '$9.99', Mint.money(9.99, 'USD').format
  end
end

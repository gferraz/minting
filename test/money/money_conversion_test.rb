# frozen_string_literal: true

class MoneyConversionTest < Minitest::Test
  def test_numeric_conversion
    nine_nine_nine = Money.from(999 / 100r, 'USD')

    assert_equal 9, nine_nine_nine.to_i
    assert_in_delta(9.99, nine_nine_nine.to_f)
    assert_equal 999 / 100r, nine_nine_nine.to_r
  end

  def test_bigdecimal_conversion
    assert_equal '9.99'.to_d,           Money.from(9.99, 'USD').to_d
    assert_equal '123_456_789.01'.to_d, Money.from(123_456_789.01, 'USD').to_d
  end
end

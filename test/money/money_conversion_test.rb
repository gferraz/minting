class MoneyConversionTest < Minitest::Test
  USD = Mint::Currency[:USD]

  def test_numeric_conversion
    nine_nine_nine = Mint::Money.new(999 / 100r, USD)

    assert_equal 9,          nine_nine_nine.to_i
    assert_equal 9.99,       nine_nine_nine.to_f
    assert_equal 999 / 100r, nine_nine_nine.to_r
    assert_equal 9.99,       nine_nine_nine.to_d
  end

end

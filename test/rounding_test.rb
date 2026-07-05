# frozen_string_literal: true

require_relative 'test_helper'

class RoundingTest < Minitest::Test
  def test_default_mode_is_half_up
    assert_equal parse('1.01'), parse('1.005')
    assert_equal parse('1.00'), parse('1.004')
  end

  def test_half_up
    Money.with_rounding(:half_up) do
      assert_equal parse('1.01'), parse('1.005')
      assert_equal parse('1.00'), parse('1.004')
    end
  end

  def test_half_down
    Money.with_rounding(:half_down) do
      assert_equal parse('1.00'), parse('1.005')
      assert_equal parse('1.01'), parse('1.006')
    end
  end

  def test_half_even
    Money.with_rounding(:half_even) do
      assert_equal parse('1.00'), parse('1.005')
      assert_equal parse('1.02'), parse('1.015')
      assert_equal parse('1.02'), parse('1.025')
      assert_equal parse('1.04'), parse('1.035')
    end
  end

  def test_floor
    Money.with_rounding(:floor) do
      assert_equal parse('1.00'), parse('1.009')
      assert_equal parse('-1.01'), Money.from(-1.001r, 'USD')
    end
  end

  def test_ceil
    Money.with_rounding(:ceil) do
      assert_equal parse('1.01'), parse('1.001')
      assert_equal parse('-1.00'), Money.from(-1.009r, 'USD')
    end
  end

  def test_truncate
    Money.with_rounding(:truncate) do
      assert_equal parse('1.00'), parse('1.009')
      assert_equal parse('-1.00'), Money.from(-1.009r, 'USD')
    end
  end

  def test_down_alias
    Money.with_rounding(:down) do
      assert_equal parse('1.00'), parse('1.009')
    end
  end

  def test_nesting_restores_outer
    Money.with_rounding(:floor) do
      Money.with_rounding(:ceil) do
        assert_equal parse('1.01'), parse('1.001')
      end
      assert_equal parse('1.00'), parse('1.001')
    end
  end

  def test_restores_default_after_block
    Money.with_rounding(:floor) { parse('1.009') }

    assert_equal parse('1.01'), parse('1.005')
  end

  def test_restores_on_exception
    assert_raises(RuntimeError) do
      Money.with_rounding(:floor) { raise 'boom' }
    end
    assert_equal parse('1.01'), parse('1.005')
  end

  def test_unknown_mode_raises
    assert_raises(ArgumentError) { Money.with_rounding(:bogus) { Money.from(1, 'USD') } }
  end

  def test_does_not_leak_into_raw_rational_operations
    Money.with_rounding(:floor) do
      assert_in_delta(1.01, Rational(1005, 1000).round(2))
      assert_in_delta(-1.01, Rational(-1005, 1000).round(2))
    end
    Money.with_rounding(:ceil) do
      assert_in_delta(1.00, Rational(1001, 1000).round(2))
    end
    Money.with_rounding(:half_down) do
      assert_in_delta(1.01, Rational(1005, 1000).round(2))
    end
  end

  def test_copy_with_respects_mode
    money = parse('1.00')

    Money.with_rounding(:half_down) do
      assert_equal :half_down, Mint::Rounding.current_mode
      assert_equal parse('1.00'), money.copy_with(amount: 1.005r)
    end
    Money.with_rounding(:ceil) do
      assert_equal :ceil, Mint::Rounding.current_mode
      assert_equal parse('1.01'), money.copy_with(amount: 1.001r)
    end
  end

  def test_allocate_respects_mode
    money = parse('10.00')
    Money.with_rounding(:half_down) do
      result = money.allocate([1, 1, 1])

      assert_equal parse('3.34'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.33'), result[2]
      assert_equal money, result.sum
    end
    Money.with_rounding(:ceil) do
      result = money.allocate([1, 1, 1])

      assert_equal parse('3.33'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.34'), result[2]
      assert_equal money, result.sum
    end
  end

  def test_split_respects_mode
    money = parse('10.00')
    Money.with_rounding(:floor) do
      result = money.split(3)

      assert_equal parse('3.34'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.33'), result[2]
      assert_equal money, result.sum
    end
    Money.with_rounding(:ceil) do
      result = money.split(3)

      assert_equal parse('3.33'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.34'), result[2]
      assert_equal money, result.sum
    end
  end

  def test_parse_respects_mode
    Money.with_rounding(:half_down) do
      assert_equal parse('1.00'), Money.parse('1.005', 'USD')
    end
    Money.with_rounding(:half_up) do
      assert_equal parse('1.01'), Money.parse('1.005', 'USD')
    end
  end

  def test_thread_isolation
    t1 = Thread.new do
      Money.with_rounding(:floor) do
        Thread.pass
        parse('1.009')
      end
    end
    t2 = Thread.new do
      Money.with_rounding(:ceil) do
        Thread.pass
        parse('1.001')
      end
    end

    assert_equal parse('1.00'), t1.value
    assert_equal parse('1.01'), t2.value
  end

  private

  def parse(str) = Money.parse(str, 'USD')
end

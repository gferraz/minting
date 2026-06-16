# frozen_string_literal: true

require_relative 'test_helper'

class RoundingTest < Minitest::Test
  def test_default_mode_is_half_up
    assert_equal parse('1.01'), parse('1.005')
    assert_equal parse('1.00'), parse('1.004')
  end

  def test_half_up
    Mint.with_rounding(:half_up) do
      assert_equal parse('1.01'), parse('1.005')
      assert_equal parse('1.00'), parse('1.004')
    end
  end

  def test_half_down
    Mint.with_rounding(:half_down) do
      assert_equal parse('1.00'), parse('1.005')
      assert_equal parse('1.01'), parse('1.006')
    end
  end

  def test_floor
    Mint.with_rounding(:floor) do
      assert_equal parse('1.00'), parse('1.009')
      assert_equal parse('-1.01'), Mint.money(-1.001r, 'USD')
    end
  end

  def test_ceil
    Mint.with_rounding(:ceil) do
      assert_equal parse('1.01'), parse('1.001')
      assert_equal parse('-1.00'), Mint.money(-1.009r, 'USD')
    end
  end

  def test_truncate
    Mint.with_rounding(:truncate) do
      assert_equal parse('1.00'), parse('1.009')
      assert_equal parse('-1.00'), Mint.money(-1.009r, 'USD')
    end
  end

  def test_down_alias
    Mint.with_rounding(:down) do
      assert_equal parse('1.00'), parse('1.009')
    end
  end

  def test_nesting_restores_outer
    Mint.with_rounding(:floor) do
      Mint.with_rounding(:ceil) do
        assert_equal parse('1.01'), parse('1.001')
      end
      assert_equal parse('1.00'), parse('1.001')
    end
  end

  def test_restores_default_after_block
    Mint.with_rounding(:floor) { parse('1.009') }

    assert_equal parse('1.01'), parse('1.005')
  end

  def test_restores_on_exception
    assert_raises(RuntimeError) do
      Mint.with_rounding(:floor) { raise 'boom' }
    end
    assert_equal parse('1.01'), parse('1.005')
  end

  def test_unknown_mode_raises
    assert_raises(ArgumentError) { Mint.with_rounding(:bogus) { Mint.money(1, 'USD') } }
  end

  def test_does_not_leak_into_raw_rational_operations
    Mint.with_rounding(:floor) do
      assert_in_delta(1.01, Rational(1005, 1000).round(2))
      assert_in_delta(-1.01, Rational(-1005, 1000).round(2))
    end
    Mint.with_rounding(:ceil) do
      assert_in_delta(1.00, Rational(1001, 1000).round(2))
    end
    Mint.with_rounding(:half_down) do
      assert_in_delta(1.01, Rational(1005, 1000).round(2))
    end
  end

  def test_change_respects_mode
    money = parse('1.00')

    Mint.with_rounding(:half_down) do
      assert_equal parse('1.00'), money.change(1.005r)
    end
    Mint.with_rounding(:ceil) do
      assert_equal parse('1.01'), money.change(1.001r)
    end
  end

  def test_allocate_respects_mode
    money = parse('10.00')
    Mint.with_rounding(:half_down) do
      result = money.allocate([1, 1, 1])

      assert_equal parse('3.34'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.33'), result[2]
      assert_equal money, result.sum
    end
    Mint.with_rounding(:ceil) do
      result = money.allocate([1, 1, 1])

      assert_equal parse('3.33'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.34'), result[2]
      assert_equal money, result.sum
    end
  end

  def test_split_respects_mode
    money = parse('10.00')
    Mint.with_rounding(:floor) do
      result = money.split(3)

      assert_equal parse('3.34'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.33'), result[2]
      assert_equal money, result.sum
    end
    Mint.with_rounding(:ceil) do
      result = money.split(3)

      assert_equal parse('3.33'), result[0]
      assert_equal parse('3.33'), result[1]
      assert_equal parse('3.34'), result[2]
      assert_equal money, result.sum
    end
  end

  def test_parse_respects_mode
    Mint.with_rounding(:half_down) do
      assert_equal parse('1.00'), Mint.parse('1.005', 'USD')
    end
    Mint.with_rounding(:half_up) do
      assert_equal parse('1.01'), Mint.parse('1.005', 'USD')
    end
  end

  def test_thread_isolation
    t1 = Thread.new do
      Mint.with_rounding(:floor) do
        Thread.pass
        parse('1.009')
      end
    end
    t2 = Thread.new do
      Mint.with_rounding(:ceil) do
        Thread.pass
        parse('1.001')
      end
    end

    assert_equal parse('1.00'), t1.value
    assert_equal parse('1.01'), t2.value
  end

  private

  def parse(str) = Mint.parse(str, 'USD')
end

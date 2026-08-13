# frozen_string_literal: true

class FinancialInvariantsTest < Minitest::Test
  SEED = 20_260_813
  ITERATIONS = 100
  CURRENCY_CODES = %w[USD JPY KWD BRL CHF].freeze
  BASE_FORMAT_OPTIONS = [
    { thousand: ',', decimal: '.' },
    { thousand: '', decimal: '.' }
  ].freeze
  EUROPEAN_FORMAT_OPTIONS = { thousand: '.', decimal: ',' }.freeze

  def setup
    @random = Random.new(SEED)
  end

  def test_generated_financial_invariants
    ITERATIONS.times do |index|
      money = generated_money

      assert_split_conserves_total(money, index)
      assert_allocation_conserves_total(money, index)
      assert_subunit_round_trip(money, index)
      assert_format_parse_round_trips(money, index)
      assert_malformed_inputs_return_nil(money, index)
    end
  end

  private

  def generated_money
    currency_code = CURRENCY_CODES.fetch(@random.rand(CURRENCY_CODES.length))
    subunits = @random.rand(-10_000_000..10_000_000)
    Money.from_subunits(subunits, currency_code)
  end

  def assert_split_conserves_total(money, index)
    slices = @random.rand(1..12)

    assert_equal money, money.split(slices).sum,
                 failure_message(index, money, "split(#{slices})")
  end

  def assert_allocation_conserves_total(money, index)
    ratios = Array.new(@random.rand(1..8)) { @random.rand(1..100) }

    assert_equal money, money.allocate(ratios).sum,
                 failure_message(index, money, "allocate(#{ratios.inspect})")
  end

  def assert_subunit_round_trip(money, index)
    rebuilt = Money.from_subunits(money.subunits, money.currency)

    assert_equal money, rebuilt, failure_message(index, money, 'from_subunits(subunits)')
  end

  def assert_format_parse_round_trips(money, index)
    format_options_for(money).each do |options|
      formatted = money.format('%<currency>s %<amount>f', **options)

      assert_equal money, Money.parse(formatted),
                   failure_message(index, money, "parse(#{formatted.inspect})")
    end
  end

  # The parser is separator-positional rather than locale-aware. A three-digit
  # fractional amount with only a comma is therefore ambiguous, so European
  # round trips are restricted to the two-decimal currencies it can identify.
  def format_options_for(money)
    return BASE_FORMAT_OPTIONS unless money.currency.subunit == 2

    BASE_FORMAT_OPTIONS + [EUROPEAN_FORMAT_OPTIONS]
  end

  def assert_malformed_inputs_return_nil(money, index)
    malformed_amounts.each do |amount|
      input = "#{money.currency_code} #{amount}"

      assert_nil Money.parse(input), failure_message(index, money, "parse(#{input.inspect})")
    end
  end

  def malformed_amounts
    left = @random.rand(1..9999).to_s
    middle = @random.rand(10..99).to_s
    right = @random.rand(1..9999).to_s

    ["#{left}--#{right}", "--#{left}", "#{left}.#{middle}.#{right}",
     "#{left},#{middle},#{right}", "#{left}-#{right}"]
  end

  def failure_message(index, money, operation)
    "seed=#{SEED}, iteration=#{index}, money=#{money.inspect}, operation=#{operation}"
  end
end

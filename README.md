# Minting

Fast, precise, and developer-friendly money handling for Ruby.

[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)

## Why Minting?

**Tired of floating-point errors in financial calculations?** Minting uses Rational numbers for perfect precision.

**Need performance?** Minting is 2× faster than alternatives for high-volume operations (often 10×+ for formatting). See the [Performance](#performance) section for full benchmarks.

**Want a clean API?** Minting provides an intuitive interface with helpful error messages.

**Looking for a proven alternative?** Check out the established [Money gem](https://github.com/RubyMoney/money) with thousands of stars on GitHub.

**Rails**? Use the [minting-rails](https://github.com/gferraz/minting-rails) companion gem

## Quick start

```ruby
require 'minting'

price = Mint.money(19.99, 'USD')       #=> [USD 19.99]
tax   = price * 0.08                   #=> [USD 1.60]
total = price + tax                    #=> [USD 21.59]

total.to_s                             #=> "$21.59"
total.currency_code                    #=> "USD"
```

## Features

- Arithmetic: `+ - * /`, unary minus, `abs`
- Comparisons: `==`, `<=>`, `zero?`, `nonzero?`, `positive?`, `negative?`
- Formatting: `to_s` with custom formats, thousand delimiters and decimal separators
- Serialization: `to_json`, `to_i`, `to_f`, `to_r`, `to_d`
- Allocation utilities: `split(quantity)`, `allocate([ratios])`
- Numeric Refinements for ergonomics: `10.dollars`, `3.euros`, `4.to_money('USD')`
- Currency registry with 117+ currencies and custom registration

## Usage

```ruby
require 'minting'

# Create money
ten = Mint.money(10, 'USD')            #=> [USD 10.00]

# Create money using Numeric refinements
using Mint

1.dollar == Mint.money(1, 'USD') #=> true
ten = 10.dollars                 #=> [USD 10.00]
4.to_money('USD')                #=> [USD 4.00]

# Comparisons
ten == 10.dollars                #=> true
ten == Mint.money(10, 'EUR')     #=> false
ten > Mint.money(9.99, 'USD')    #=> true

# Zero equality semantics
# Any zero amount is treated as equal, regardless of currency 
Mint.money(0, 'USD') == Mint.money(0, 'EUR')  #=> true
Mint.money(0, 'USD') == 0                      #=> true
Mint.money(0, 'USD') == 0.0                    #=> true
Mint.money(0, 'USD') == 0r                     #=> true

# Non-zero numerics are not equal to Money objects
Mint.money(10, 'USD') == 10                    #=> false

# Format (uses Kernel.format internally)
price = Mint.money(9.99, 'USD')

price.to_s                                  #=> "$9.99",
price.to_s(format: '%<amount>d')            #=> "9",
price.to_s(format: '%<symbol>s%<amount>f')  #=> "$9.99",
price.to_s(format: '%<symbol>s%<amount>+f') #=> "$+9.99",
(-price).to_s(format: '%<amount>f')         #=> "-9.99",

# Format with padding
price_in_euros = Mint.money(12.34, 'EUR')

price.to_s(format: '--%<amount>7d')               #=> "--      9"
price.to_s(format: '  %<amount>10f %<currency>s') #=> "        9.99 USD"
(-price).to_s(format: '  %<amount>10f')           #=> "       -9.99"

price_in_euros.to_s(format: '%<symbol>2s%<amount>+10f')    #=> " €    +12.34"

# Json serialization

price.to_json # => "{\"currency\": \"USD\", \"amount\": \"9.99\"}"

# Hash conversion

price.to_hash #=> {currency: "USD", amount: "9.99"}


# Fractional units (inverse of #fractional) - exact integer arithmetic

price.fractional                        #=> 999
Mint::Money.from_fractional(999, 'USD') #=> [USD 9.99]
Mint::Money.from_fractional(1234, 'JPY') #=> [JPY 1234]  # subunit 0 -> no scaling


# Proportional allocation and split

ten.split(3)                           #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
ten.allocate([1, 2, 3])                #=> [[USD 1.67], [USD 3.33], [USD 5.00]]

# Ranges and enumeration are supported

1.dollar..10.dollars                      #=> [USD 1.00]..[USD 10.00]
(1.dollar..3.dollars).step(1.dollar).to_a #=> [[USD 1.00], [USD 2.00], [USD 3.00]]

```

## API notes

**Module names** — Require the `minting` gem; the public API lives under `Mint`.

**Exact amounts** — Amounts are stored as `Rational` and rounded to the currency subunit.

**Refinements** — `10.dollars` and similar helpers require `using Mint` in the current scope (see Usage above).

**Division** — `money / 5` returns new `Money`; `money / other_money` returns a numeric ratio, not money.

**Zero equality** — Any zero amount is considered equal across currencies and to numeric zero `Mint.money(0, 'USD') == Mint.money(0, 'EUR')` is intentionally `true`. Non-zero amounts must match currency and value.

**Custom currencies** — `Mint.register_currency` returns the existing entry if the code is already registered; use `register_currency!` to detect duplicates.

**Built-in currencies** — ISO-style codes ship in `lib/minting/data/currencies.yaml` and load when the registry is first accessed.

## Installation

Option 1: Via bundler command

```shell
bundle add minting
bundle install
```

Option 2: add the line below to your application's Gemfile:

```ruby
gem 'minting'
```

or, if you want latest development version from Github

```ruby
gem 'minting', git: 'https://github.com/gferraz/minting.git'
```

and execute:

```shell
bundle install
```

Option 3: Install it yourself with:

```shell
gem install minting
```

## Parsing strings

```ruby
Mint::Money.parse('$19.99')           #=> [USD 19.99]
Mint::Money.parse('19,99 €')          #=> [EUR 19.99]
Mint::Money.parse('1.234,56', 'EUR')  #=> [EUR 1234.56]
Mint::Money.parse('USD 1,234.56')     #=> [USD 1234.56]
```

- Pass a currency code when the string has no symbol or code. 
- 1,234 means 1.234, not 1234, because one comma is treated as decimal.
- 1,234.00 is unambiguous thousands-plus-decimal.
- accounting negatives like ($1.23) are unsupported.
- ambiguous symbols like $ resolve by priority, currently USD.

## Roadmap

- Improve formatting features
- Localization (I18n-aware formatting)
- Basic exchange-rate conversions

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/gferraz/minting>.

1. Fork and create a feature branch
2. Run the test suite: `rake`
3. Run performance suites as needed: `BENCH=true rake bench:performance`
4. Open a PR with a clear description and benchmarks if relevant


## Performance

This gem includes a performance suite under `test/performance`:

- Core operations (creation, arithmetic, comparisons)
- Algorithm benchmarks (split, allocate)
- Memory and GC pressure tests
- Competitive benchmarks vs `money` gem

Run locally:

```bash
# All performance suites
BENCH=true rake bench:performance

# Competitive vs money gem
BENCH=true rake bench:competitive

# Regression checks
rake bench:regression
```

## Benchmark Summary: Minting vs Money Gem

Generated by Qwen from the latest benchmark run on Ruby 4.0.1. - 2026-05-30

### Key Takeaways

- **Mint is consistently faster** than the Money gem across all measured operations.
- **Mint is 2.28x faster** in the 50,000-transaction simulation.
- **Mint object creation is 2.76x faster** than `Money.from_amount`.
- In formatting and conversion, Mint is often **10+x **.
- Mint’s performance advantage is especially strong for numeric conversion, string formatting, comparisons, and high-volume transaction loops.

### Performance Highlights

| Category | Mint | Money | Approx. Ratio |
| --- | --- | --- | --- |
| High-volume transactions | 195,412 ops/sec | 85,882 ops/sec | 2.28x faster |
| `Mint.money` creation | 1.14M ops/sec | — | 2.76x faster than `Money.from_amount` |
| `some.dollars` creation | 990k ops/sec | — | 1.15x faster than `Mint.money` |
| `Money.new` creation | — | 715k ops/sec | Mint 1.59x faster |
| `to_f` formatting | 8.8M–9.3M ops/sec | 0.7M ops/sec | ~12x faster |
| `to_d` conversion | 2.1M–2.3M ops/sec | 0.73M–0.79M ops/sec | ~3x faster |
| `to_s` formatting | 300k–420k ops/sec | 109k–132k ops/sec | ~3x faster |
| `inspect` formatting | ~2.6–2.9M ops/sec | ~1.1–1.16M ops/sec | ~2.5x faster |
| `to_json` formatting | ~2.0–2.2M ops/sec | ~110k–126k ops/sec | ~17x faster |
| Currency lookup `Mint.currency('USD')` | 3.82M ops/sec | — | 1.60x faster than `Money::Currency.new` |
| Currency lookup `Money::Currency.find('USD')` | 3.63M ops/sec | 1.67M ops/sec | 2.29x faster |
| Addition | 1.11M ops/sec | 0.37M ops/sec | 3.0x faster |
| Subtraction | 1.11M ops/sec | 0.36M ops/sec | 3.0x faster |
| Multiplication | 1.28M ops/sec | 0.51M ops/sec | 2.5x faster |
| Division | 1.04M ops/sec | 0.37M ops/sec | 2.8x faster |
| Ratio division | 2.94M ops/sec | 0.39M ops/sec | 7.6x faster |
| Comparison (`==`, `<`, `>`) | 2.5M–4.1M ops/sec | 0.35M–0.38M ops/sec | 7x–10x faster |
| Allocation (`Mint.allocate`) | 279k ops/sec | 146k ops/sec | 1.9x faster |
| Split (`Mint.split`) | 215k ops/sec | 85k ops/sec | 3.3x faster |

### Commands Used

```sh
BENCH=true bundle exec ruby -Ilib:test -r ./test/test_helper.rb test/performance/competitive_performance_benchmark.rb
BENCH=true bundle exec ruby -Ilib:test -r ./test/test_helper.rb test/performance/competitive_memory_benchmark.rb
```

## License

MIT

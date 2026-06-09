# Minting

Fast, precise, and developer-friendly money handling for Ruby.

[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)

## Why Minting?

**Tired of floating-point errors in financial calculations?** Minting uses Rational numbers for perfect precision.

**Need performance?** Minting is 2× faster than alternatives for high-volume operations (often 10×+ for formatting). See the [Performance](https://github.com/gferraz/minting/blob/master/test/performance/README.md) section for full benchmarks.

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
- Allocation utilities: `split(quantity)`, `allocate([ratios])`, 
- Utilities: `clamp(min, max)`
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

# Per-sign Hash format (e.g. accounting parentheses for losses)
loss = Mint.money(-1234.56, 'USD')
loss.to_s(format: { negative: '(%<symbol>s%<amount>f)' })  #=> "($1,234.56)"
Mint.money(0, 'BRL').to_s(format: { zero: '--' })          #=> "--"
# All three keys at once:
fmt = { positive: '%<symbol>s%<amount>f', negative: '(%<symbol>s%<amount>f)', zero: '--' }
Mint.money(1234.56, 'USD').to_s(format: fmt)               #=> "$1,234.56"

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

# Clamping to a range

price = Mint.money(50, 'USD')
min_price = Mint.money(75, 'USD')

price.clamp(0, 100)                    #=> [USD 50.00]  (returns self, no new object)
price.clamp(0, 25)                     #=> [USD 25.00]  (clamped to max)
price.clamp(min_price, 100)                   #=> [USD 75.00]  (clamped to min)

# Clamp accepts Money bounds or Numeric amounts
price.clamp(min_price, 100) #=> [USD 75.00]

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

**Custom currencies** — `Mint.register_currency`, Only registered currency codes and symbolos are recoginized by the parser.

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
Mint.parse('$19.99')           #=> [USD 19.99]
Mint.parse('19,99 €')          #=> [EUR 19.99]
Mint.parse('1.234,56', 'EUR')  #=> [EUR 1234.56]
Mint.parse('USD 1,234.56')     #=> [USD 1234.56]
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
3. Run performance suites as needed: `rake bench:performance`
4. Open a PR with a clear description and benchmarks if relevant


## License

MIT

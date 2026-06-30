# Minting

Fast, precise, and developer-friendly money handling for Ruby.

[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)
[![CI](https://github.com/gferraz/minting/actions/workflows/ci.yml/badge.svg)](https://github.com/gferraz/minting/actions/workflows/ci.yml)
[![Test Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](https://github.com/gferraz/minting)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue)](https://www.rubydoc.info/gems/minting/frames)

## Quick start

```ruby
require 'minting'

price = Mint.money(19.99, 'USD')       #=> [USD 19.99]
tax   = price * 0.08                   #=> [USD 1.60]
total = price + tax                    #=> [USD 21.59]

total.to_s                             #=> "$21.59"
total.currency_code                    #=> "USD"
```

### Exact precision
Amounts are stored as `Rational` and rounded to the currency subunit. No floating-point surprises, ever.

### Blazing performance
Minting is faster than the Money gem for everyday operations and **over 10× faster for formatting**. See full benchmarks in the [Performance Guide](test/performance/BENCHMARKS.md).

### Clean, modern API
Intuitive interface, descriptive error messages, and sensible defaults. Works the way you expect.

### Rails-ready
Use with the [attribute-money](https://github.com/gferraz/attribute-money) companion gem for drop-in ActiveRecord type casting, validators, and form helpers.

### Quality code
- **100% test coverage** — every line exercised
- **94/100 RubyCritic score** — clean, maintainable code
- **CI-tested on Ruby 3.3 and 4.0**

## Installation

```shell
bundle add minting
```

Or add to your Gemfile:

```ruby
gem 'minting'
```

## Usage

```ruby
require 'minting'

# Create money
ten = Mint.money(10, 'USD')            #=> [USD 10.00]

1.dollar == Mint.money(1, 'USD') #=> true
ten = 10.dollars                 #=> [USD 10.00]
4.to_money('USD')                #=> [USD 4.00]

# Comparisons
ten == 10.dollars                #=> true
ten == Mint.money(10, 'EUR')     #=> false
ten > Mint.money(9.99, 'USD')    #=> true

# Zero equality semantics
# Any zero amount is treated as equal, regardless of currency
Mint.money(0, 'USD') == Mint.money(0, 'EUR')   #=> true
Mint.money(0, 'USD') == 0                      #=> true
Mint.money(0, 'USD') == 0.0                    #=> true

# Non-zero numerics are not equal to Money objects
Mint.money(10, 'USD') == 10                    #=> false

# Format (uses Kernel.format syntax)
price = Mint.money(9.99, 'USD')
loss  = Mint.money(-1234.56, 'USD')

# Built-in named presets
loss.format(:accounting)                      #=> "($1,234.56)"
Mint.money(1234.56, 'EUR').format(:european)  #=> "1.234,56 €"
price.format(:amount)                         #=> "9.99"
price.format(:currency)                       #=> "USD 9.99"

# Presets can be overridden with explicit kwargs
Mint.money(1234.56, 'EUR').format(:european, format: '%<amount>f %<currency>s')
#=> "1.234,56 EUR"

# Or use direct format strings
price.format                                  #=> "$9.99",
price.format(format: '%<amount>d')            #=> "9",
price.format(format: '%<symbol>s%<amount>f')  #=> "$9.99",
price.format(format: '%<symbol>s%<amount>+f') #=> "$+9.99",
(-price).format(format: '%<amount>f')         #=> "-9.99",

# Format with padding
price_in_euros = Mint.money(12.34, 'EUR')

price.format(format: '--%<amount>7d')               #=> "--      9"
price.format(format: '  %<amount>10f %<currency>s') #=> "        9.99 USD"
(-price).format(format: '  %<amount>10f')           #=> "       -9.99"

price_in_euros.format(format: '%<symbol>2s%<amount>+10f')    #=> " €    +12.34"

# Integral & fractional parts
price.format(format: '%<integral>d %<fractional>d/100')        #=> "9 99/100"
Mint.money(0.99, 'USD').format(format: '%<integral>d dollars and %<fractional>02d cents')
#=> "0 dollars and 99 cents"

# Per-sign Hash format (e.g. accounting parentheses for losses)
loss = Mint.money(-1234.56, 'USD')
loss.format(format: { negative: '(%<symbol>s%<amount>f)' })  #=> "($1,234.56)"
Mint.money(0, 'BRL').format(format: { zero: '--' })          #=> "--"
# All three keys at once:
fmt = { positive: '%<symbol>s%<amount>f', negative: '(%<symbol>s%<amount>f)', zero: '--' }
Mint.money(1234.56, 'USD').format(format: fmt)               #=> "$1,234.56"

# Disambiguated symbol (e.g. "US$" vs "C$" vs "A$")
Mint.money(10, 'USD').format(format: '%<dsymbol>s%<amount>f')  #=> "US$10.00"
Mint.money(10, 'CAD').format(format: '%<dsymbol>s%<amount>f')  #=> "C$10.00"
Mint.money(10, 'EUR').format(format: '%<dsymbol>s%<amount>f')  #=> "€10.00"  (no dsymbol, falls back to symbol)

# Json serialization

price.to_json # => "{\"currency\": \"USD\", \"amount\": \"9.99\"}"

# Hash conversion

price.to_hash #=> {currency: "USD", amount: "9.99"}


# Fractional units (inverse of #fractional) - exact integer arithmetic

price.subunits                        #=> 999
Mint::Money.from_subunits(999, 'USD') #=> [USD 9.99]
Mint::Money.from_subunits(1234, 'JPY') #=> [JPY 1234]  # subunit 0 -> no scaling


# No currency (ISO 4217 XXX)

Mint::Money.no_currency(100) #=> [XXX 100]
Mint::Money.no_currency(0)   #=> [XXX 0]


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

## Parsing strings

```ruby
Mint.parse('$19.99')           #=> [USD 19.99]
Mint.parse('19,99 €')          #=> [EUR 19.99]
Mint.parse('1.234,56', 'EUR')  #=> [EUR 1234.56]
Mint.parse('USD 1,234.56')     #=> [USD 1234.56]
```

Notes:
- Pass a currency code when the string has no symbol or code.
- `1,234` means 1234, not 1.234 and `1,23` means 1.23, not 123
- `1,234.00` is unambiguous (thousands + decimal).
- Accounting negatives like `($1.23)` or `(USD 10.00)` are supported — the parser detects parentheses and negates the amount.
- Ambiguous symbols like `$` resolve by currency priority (currently USD).
- The parser scans all uppercase words for registered codes, so spurious non-currency words before the real code are correctly ignored: `Mint.parse("MAX 10.00 USD")` yields `[USD 10.00]`.

## Currency lookup

```ruby
# By ISO code (direct hash lookup, string only)
Mint::Currency.for_code('USD')        #=> #<Currency code="USD" ...>

# By display symbol (highest-priority currency for ambiguous symbols)
Mint::Currency.for_symbol('$')        #=> #<Currency code="USD" ...>
Mint::Currency.for_symbol('R$')       #=> #<Currency code="BRL" ...>
Mint::Currency.for_symbol('€')        #=> #<Currency code="EUR" ...>

```

## API notes

**Exact amounts** — Amounts are stored as `Rational` and rounded to the currency subunit.

**Rounding modes** — Wrap operations in `Mint.with_rounding(mode)` to change how amounts are rounded to the subunit:

```ruby
Mint.with_rounding(:half_down) { Mint.money(1.005, 'USD') }  #=> [USD 1.00]
Mint.with_rounding(:ceil)      { Mint.money(1.001, 'USD') }  #=> [USD 1.01]
Mint.with_rounding(:floor)     { Mint.parse('1.009', 'USD') } #=> [USD 1.00]
```

Modes: `:half_up` (default), `:half_down`, `:floor`, `:ceil`, `:truncate`, `:down`. Applies to construction, parsing, `change`, `split`, and `allocate`. Restores the previous mode when the block exits, even on exception.

> **Performance note:** Rounding-mode support is not loaded by default — `require 'minting'` uses the fastest possible rounding (equivalent to `:half_up`) with zero dispatch overhead. The first call to `Mint.with_rounding` loads the rounding module and patches `Currency#normalize_amount`, adding ~10–35 ns per money creation or mutation. If your application never uses custom rounding modes (the common case), there is **no performance cost**.

**Division** — `money / 5` returns new `Money`; `money / other_money` returns a numeric ratio, not money.

**Zero equality** — Any zero amount is considered equal across currencies and to numeric zero (`Mint.money(0, 'USD') == Mint.money(0, 'EUR')` is intentionally `true`). Non-zero amounts must match currency and value.

**Zero helper** — `Currency.zero('USD')` returns a frozen zero-Money, useful as a default value for discounts, totals, or counters.

**Registered currencies** — `Currency.register(code:, subunit:, symbol:, priority:)` adds custom currencies. Only registered codes and symbols are recognized by the parser or searches. Nonetheless, you don't need to register a currency to use it with most of the features.

**Built-in currencies** — 150+ ISO-4217 world currencies ship in `lib/minting/data/currencies.yaml` and load when the registry is first accessed.

## Optional top-level `Money` and `Currency`

By default, `require "minting"` exposes `Mint::Money` as the top-level `Money` constant, so you can write `Money.from(10, "USD")` directly:

```ruby
require "minting"

price = Money.from(10, "USD")                   # equivalent to Mint::Money.from
tax   = Money.from(2.50, "USD")
```

`Currency` is **not** auto-bound, because application domain models are commonly named `Currency` (e.g. a Rails model). To opt in to the top-level `Currency` constant:

```ruby
require "minting"
require "minting/mint/aliases"  # opt-in top-level Currency

cur = Currency.new(code: "EUR", symbol: "€", subunit: 2, priority: 0)
```

For Rails applications, you can enable the top-level `Currency` constant in an initializer:

```ruby
# config/initializers/minting.rb
require "minting/mint/aliases"
```

If another `Money` is already defined when `require "minting"` runs (e.g. the `money` gem was loaded first), Minting warns and skips the auto-bind — use `Mint::Money` in that case. The same applies to `Currency` via `minting/mint/aliases`.

**Good fit:** Application code, especially Rails apps.
**Not recommended:** Reusable gems/libraries — stick to `Mint::Money` to avoid conflicts.

## Roadmap

- Exchange-rate conversion infrastructure

## License

MIT

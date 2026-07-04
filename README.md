[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)
[![CI](https://github.com/gferraz/minting/actions/workflows/ci.yml/badge.svg)](https://github.com/gferraz/minting/actions/workflows/ci.yml)
[![Test Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](https://github.com/gferraz/minting)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue)](https://www.rubydoc.info/gems/minting/frames)

# Minting

**Fast, precise, and developer-friendly money handling for Ruby.**



> **Status:** Minting is approaching a stable 2.0 release. The core API (`Money`, `Currency`, formatting, parsing) is settling and breaking changes from here should be rare. See [Roadmap](#roadmap) for what's left before the tag.

```ruby
price = Money.from(19.99, 'USD')       #=> [USD 19.99]
tax   = price * 0.08                   #=> [USD 1.60]
total = price + tax                    #=> [USD 21.59]

total.to_s                             #=> "$21.59"
```

Amounts are stored as `Rational`, so there's no floating-point drift — `0.1 + 0.2` problems simply don't happen here, at any scale.

## Table of contents

- [Why Minting](#why-minting)
- [How it compares](#how-it-compares)
- [Installation](#installation)
- [Usage](#usage)
  - [Creating & comparing money](#creating--comparing-money)
  - [Formatting](#formatting)
  - [Fractional units & allocation](#fractional-units--allocation)
  - [Parsing strings](#parsing-strings)
  - [Currency lookup](#currency-lookup)
  - [Crypto currencies](#crypto-currencies)
  - [Locale formatting](#locale-formatting)
- [API notes](#api-notes)
- [Optional top-level `Money` and `Currency`](#optional-top-level-money-and-currency)
- [Rails integration](#rails-integration)
- [Roadmap](#roadmap)
- [License](#license)

## Why Minting

Minting started as a personal project to learn what it actually takes to build and maintain a real open source Ruby gem — not exactly as a reaction against any existing library. That origin shows in how it's built: it's grown deliberately, with an emphasis on correctness and a clean API.

What it's become along the way:

- **Exact by construction** — amounts are `Rational` internally, rounded to the currency's subunit only when needed. No silent precision loss from repeated arithmetic.
- **No Rails dependency** — Minting is a plain Ruby gem. Use it in a script, a Sinatra app, a background job runner, or a Rails app — your choice, not the gem's.
- **Formatting that doesn't fight you** — `Kernel.format`-style templates, named presets (`:accounting`, `:european`), per-sign formats (parentheses for negatives), and a pluggable locale hook.
- **Built for real-world currency handling** — 150+ ISO-4217 currencies, correct subunit handling (JPY has none, KWD has three), proportional allocation/split that doesn't lose cents to rounding.
- **Measured, not assumed, performance** — see the [Performance Guide](bench/BENCHMARKS.md) for actual benchmarks rather than claims.
- **Rails-ready without being Rails-only** — pair with the companion [MoneyAttribute](https://github.com/gferraz/money-attribute) gem for `ActiveRecord` type casting, validators, and form helpers.

## How it compares

A few structural differences from the `money` gem (and `money-rails`), for anyone evaluating both:

| | **Minting** | **Money** |
|---|---|---|
| Internal representation | `Rational` | `BigDecimal` (float-backed input coercion) |
| Rails integration | via `money_attribute` gem | via `money-rails` gem |
| Exchange rates | Pluggable provider architecture *(planned)* | Built-in bank/exchange abstraction |
| Currency data | Ships with the gem | Ships with the gem |

## Installation

```shell
bundle add minting
```

Or add to your Gemfile:

```ruby
gem 'minting'
```

## Usage

### Creating & comparing money

```ruby
require 'minting'

ten = Money.from(10, 'USD')            #=> [USD 10.00]

1.dollar == Money.from(1, 'USD')       #=> true
ten = 10.dollars                       #=> [USD 10.00]
4.to_money('USD')                      #=> [USD 4.00]

# Comparisons
ten == 10.dollars                      #=> true
ten == Money.from(10, 'EUR')           #=> false
ten > Money.from(9.99, 'USD')          #=> true

# Zero equality semantics
# Any zero amount is treated as equal, regardless of currency
Money.from(0, 'USD') == Money.from(0, 'EUR')   #=> true
Money.from(0, 'USD') == 0                      #=> true
Money.from(0, 'USD') == 0.0                    #=> true

# Non-zero numerics are not equal to Money objects
Money.from(10, 'USD') == 10                    #=> false

# Ranges and enumeration are supported
1.dollar..10.dollars                      #=> [USD 1.00]..[USD 10.00]
(1.dollar..3.dollars).step(1.dollar).to_a #=> [[USD 1.00], [USD 2.00], [USD 3.00]]

# Clamping to a range
price = Money.from(50, 'USD')
min_price = Money.from(75, 'USD')

price.clamp(0, 100)          #=> [USD 50.00]  (returns self, no new object)
price.clamp(0, 25)           #=> [USD 25.00]  (clamped to max)
price.clamp(min_price, 100)  #=> [USD 75.00]  (clamped to min, Money or Numeric bounds both work)
```

### Formatting

```ruby
price = Money.from(9.99, 'USD')
loss  = Money.from(-1234.56, 'USD')

# Built-in named presets
loss.format(:accounting)                      #=> "($1,234.56)"
Money.from(1234.56, 'EUR').format(:european)  #=> "1.234,56 €"
price.format(:amount)                         #=> "9.99"
price.format(:currency)                       #=> "USD 9.99"

# Presets can be overridden with explicit kwargs
Money.from(1234.56, 'EUR').format(:european, format: '%<amount>f %<currency>s')
#=> "1.234,56 EUR"

# Or use direct format strings
price.format                                  #=> "$9.99"
price.format(format: '%<amount>d')            #=> "9"
price.format(format: '%<symbol>s%<amount>f')  #=> "$9.99"
price.format(format: '%<symbol>s%<amount>+f') #=> "$+9.99"
(-price).format(format: '%<amount>f')         #=> "-9.99"

# Format with padding
price_in_euros = Money.from(12.34, 'EUR')

price.format(format: '--%<amount>7d')               #=> "--      9"
price.format(format: '  %<amount>10f %<currency>s') #=> "        9.99 USD"
(-price).format(format: '  %<amount>10f')           #=> "       -9.99"
price_in_euros.format(format: '%<symbol>2s%<amount>+10f')    #=> " €    +12.34"

# Integral & fractional parts
price.format(format: '%<integral>d %<fractional>d/100')        #=> "9 99/100"
Money.from(0.99, 'USD').format(format: '%<integral>d dollars and %<fractional>02d cents')
#=> "0 dollars and 99 cents"

# Per-sign Hash format (e.g. accounting parentheses for losses)
loss.format(format: { negative: '(%<symbol>s%<amount>f)' })  #=> "($1,234.56)"
Money.from(0, 'BRL').format(format: { zero: '--' })          #=> "--"
fmt = { positive: '%<symbol>s%<amount>f', negative: '(%<symbol>s%<amount>f)', zero: '--' }
Money.from(1234.56, 'USD').format(format: fmt)               #=> "$1,234.56"

# Disambiguated symbol (e.g. "US$" vs "C$" vs "A$")
Money.from(10, 'USD').format(format: '%<dsymbol>s%<amount>f')  #=> "US$10.00"
Money.from(10, 'CAD').format(format: '%<dsymbol>s%<amount>f')  #=> "C$10.00"
Money.from(10, 'EUR').format(format: '%<dsymbol>s%<amount>f')  #=> "€10.00" (falls back to symbol)

# Hash serialization
price.to_hash   #=> {currency: "USD", amount: "9.99"}
```

### Integral & fractional parts

```ruby
price.integral    #=> 9         # whole-unit part
price.fractional  #=> 99        # fractional part (subunits within one unit)
price.subunits    #=> 999       # total amount in smallest unit

Mint::Money.from_subunits(999, 'USD')  #=> [USD 9.99]
Mint::Money.from_subunits(1234, 'JPY') #=> [JPY 1234]  # subunit 0 -> no scaling

# No currency (ISO 4217 XXX)
Mint::Money.no_currency(100) #=> [XXX 100]
Mint::Money.no_currency(0)   #=> [XXX 0]

# Proportional allocation and split
ten = 10.dollars
ten.split(3)                 #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
ten.allocate([1, 2, 3])       #=> [[USD 1.67], [USD 3.33], [USD 5.00]]
```

### Parsing strings

```ruby
Money.parse('$19.99')           #=> [USD 19.99]
Money.parse('19,99 €')          #=> [EUR 19.99]
Money.parse('1.234,56', 'EUR')  #=> [EUR 1234.56]
Money.parse('USD 1,234.56')     #=> [USD 1234.56]
```

Notes:
- Pass a currency code when the string has no symbol or code.
- `1,234` means 1234, not 1.234, and `1,23` means 1.23, not 123.
- `1,234.00` is unambiguous (thousands + decimal).
- Accounting negatives like `($1.23)` or `(USD 10.00)` are supported — the parser detects parentheses and negates the amount.
- Ambiguous symbols like `$` resolve by currency priority (currently USD).
- The parser scans all uppercase words for registered codes, so spurious non-currency words before the real code are correctly ignored: `Money.parse("MAX 10.00 USD")` yields `[USD 10.00]`.

### Currency lookup

```ruby
# All registered currencies (150+ ISO 4217 + custom)
Money::Currency.registered_currencies.size                 #=> 154
Money::Currency.registered_currencies.each { |code, c| puts "#{code}: #{c.name}" }

# Built-in ISO 4217 currencies (before custom registrations)
Money::Currency.world_currencies.size    #=> 154

# By ISO code (direct hash lookup, string only)
Money::Currency.for_code('USD')        #=> #<Currency code="USD" ...>

# By display symbol (highest-priority currency for ambiguous symbols)
Money::Currency.for_symbol('$')        #=> #<Currency code="USD" ...>
Money::Currency.for_symbol('R$')       #=> #<Currency code="BRL" ...>
Money::Currency.for_symbol('€')        #=> #<Currency code="EUR" ...>
```

**Polymorphic currency resolution** — `Currency.resolve` also accepts objects that implement `#to_currency` or `#currency_code`:

```ruby
class Product
  def currency_code = 'USD'
end

Money::Currency.resolve(Product.new)  #=> #<Currency code="USD" ...>
Money::Currency.resolve!(Product.new) # raises Mint::UnknownCurrency if code is unknown
```

`#to_currency` takes precedence when both methods exist. It must return a `Currency` object; `#currency_code` must return a `String`. Wrong types raise `ArgumentError`.

### Crypto currencies

Minting ships with opt-in definitions for ~25 popular crypto currencies (BTC, ETH, SOL, ...). They are not registered by default — use `register_crypto` to enable them:

```ruby
Currency.register_crypto('BTC', 'ETH', 'SOL')

Mint.parse("0.01 BTC")    #=> [BTC 0.01000000]
Mint.money(1, 'ETH')      #=> [ETH 1.000000000000000000]
```

`Currency.crypto_currencies` lists all available definitions without registering:

```ruby
Currency.crypto_currencies.each { |c| puts "#{c.code}: #{c.name}" }
# BTC: Bitcoin
# ETH: Ethereum
# SOL: Solana
# ...
```

`register_crypto` raises `KeyError` on duplicate codes and `ArgumentError` on unknown codes. Register all at once:

```ruby
# Register all at once:
Currency.register_all_crypto   # raises KeyError on any conflict
```

`Currency.crypto_currencies` lists all available definitions without registering:

```ruby
Currency.crypto_currencies.each { |c| puts "#{c.code}: #{c.name}" }
# BTC: Bitcoin
# ETH: Ethereum
# SOL: Solana
# ...
```

### Locale formatting

Minting doesn't ship built-in locale data, but the `Mint.locale_backend` hook lets you wire in locale-specific decimal/thousand separators and format templates:

```ruby
LOCALE_DATA = {
  'en'    => { decimal: '.', thousand: ',', format: '%<symbol>s%<amount>f' },
  'pt'    => { decimal: ',', thousand: '.', format: '%<symbol>s%<amount>f' },
  'pt-BR' => { decimal: ',', thousand: '.', format: '%<symbol>s%<amount>f' },
  'de'    => { decimal: ',', thousand: '.', format: '%<amount>f %<currency>s' },
  'fr'    => { decimal: ',', thousand: ' ', format: '%<amount>f %<symbol>s' },
  'ja'    => { decimal: '.', thousand: ',', format: '%<symbol>s%<amount>f' },
}.freeze

Mint.locale_backend = ->(locale) { LOCALE_DATA[locale.to_s] || {} }

Mint.money(1234.56, 'USD').format(locale: :en)  #=> "$1,234.56"
Mint.money(9.99, 'BRL').format(locale: 'pt')    #=> "R$9,99"
Mint.money(9.99, 'EUR').format(locale: :de)     #=> "9,99 EUR"
Mint.money(9.99, 'EUR').format(locale: 'fr')    #=> "9,99 €"
Mint.money(9.99, 'USD').format(locale: :ja)     #=> "$9.99"
```

Pass `locale:` as a keyword to `format` / `to_fs`. Accepts both symbols (`:en`, `:'pt-BR'`) and strings (`'pt-BR'`, `'en-US'`) — passed through as-is, matching Rails' `I18n.locale` convention. The backend returns a hash with `:decimal`, `:thousand`, and optionally `:format` (defaults to `'%<symbol>s%<amount>f'`). String and symbol keys are interchangeable. Return `{}` or `nil` for unknown locales — defaults apply.

Rails I18n key names (`:separator`, `:delimiter`) are also accepted — no mapping needed:

```ruby
Mint.locale_backend = ->(locale = nil) {
  I18n.with_locale(locale || I18n.default_locale) do
    I18n.t('number.currency.format', default: {})
  end
}
```

Minting names take precedence when both are present (e.g. `{ decimal: '.', separator: ',' }` uses `'.'`).

Arity-0 callables (`-> { ... }`) are called without arguments and work unchanged:

```ruby
Mint.locale_backend = -> { { decimal: ',', thousand: '.' } }
Mint.money(9.99, 'BRL').format  #=> "R$9,99"
```

## API notes

**Exact amounts** — Amounts are stored as `Rational` and rounded to the currency subunit.

**Rounding modes** — Wrap operations in `Money.with_rounding(mode)` to change how amounts are rounded to the subunit:

```ruby
Money.with_rounding(:half_down) { Money.from(1.005, 'USD') }   #=> [USD 1.00]
Money.with_rounding(:ceil)      { Money.from(1.001, 'USD') }   #=> [USD 1.01]
Money.with_rounding(:floor)     { Money.parse('1.009', 'USD') } #=> [USD 1.00]
```

Modes: `:half_up` (default), `:half_down`, `:floor`, `:ceil`, `:truncate`, `:down`. Applies to construction, parsing, `change`, `split`, and `allocate`. Restores the previous mode when the block exits, even on exception.

> **Performance note:** Rounding-mode support is not loaded by default — `require 'minting'` uses the fastest possible rounding (equivalent to `:half_up`) with zero dispatch overhead. The first call to `Money.with_rounding` loads the rounding module and patches `Currency#normalize_amount`, adding ~10–35 ns per money creation or mutation. If your application never uses custom rounding modes, there is **no performance cost**.

**Division** — `money / 5` returns new `Money`; `money / other_money` returns a numeric ratio, not money.

**Zero equality** — Any zero amount is considered equal across currencies and to numeric zero (`Money.from(0, 'USD') == Money.from(0, 'EUR')` is intentionally `true`). Non-zero amounts must match currency and value.



**Registered currencies** — `Currency.register(code:, subunit:, symbol:, priority:)` adds custom currencies. Only registered codes and symbols are recognized by the parser or searches. You don't need to register a currency to use it with most features.

**Built-in currencies** — 150+ ISO-4217 world currencies ship in `lib/minting/data/currencies.yaml` and load when the registry is first accessed.

## Optional top-level `Money` and `Currency`

By default, `require "minting"` exposes `Mint::Money` as the top-level `Money` constant, so you can write `Money.from(10, "USD")` directly:

```ruby
require "minting"

price = Money.from(10, "USD")   # equivalent to Mint::Money.from
tax   = Money.from(2.50, "USD")
```

`Currency` is **not** auto-bound, because application domain models are commonly named `Currency` (e.g. a Rails model). To opt in to the top-level `Currency` constant:

```ruby
require "minting"
require "minting/aliases"  # opt-in top-level Currency

cur = Currency.new(code: "EUR", symbol: "€", subunit: 2, priority: 0)
```

For Rails applications, enable it in an initializer:

```ruby
# config/initializers/minting.rb
require "minting/aliases"
```

If another `Money` is already defined when `require "minting"` runs (e.g. the `money` gem was loaded first), Minting warns and skips the auto-bind — use `Mint::Money` in that case. The same applies to `Currency` via `minting/aliases`.

**Good fit:** Application code, especially Rails apps.
**Not recommended:** Reusable gems/libraries — stick to `Mint::Money` to avoid conflicts.

## Rails integration

Minting itself has no Rails dependency. For `ActiveRecord` type casting, validators, and form helpers, pair it with the companion gem:

- **[MoneyAttribute](https://github.com/gferraz/money-attribute)** — a `money_attribute` macro for models, with `ActiveRecord::Type` integration and `composed_of`-based support for multi-column (amount + currency) attributes.

## Roadmap

Toward a stable 2.0: (no later than August 2026)

- Exchange-rate conversion infrastructure (provider abstraction, stateless injection)
- API surface review — locking in the public interface for `Money`, `Currency`, and formatting before the tag

## License

MIT

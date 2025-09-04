# Minting

Fast, precise, and developer-friendly money handling for Ruby.

[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)

## Why Minting?

**Tired of floating-point errors in financial calculations?** Minting uses Rational numbers for perfect precision.

**Need performance?** Minting is 2x faster than alternatives.

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
- Formatting: `to_s` with custom formats, delimiters, separators
- Serialization: `to_json`, `to_i`, `to_f`, `to_r`, `to_d`
- Allocation utilities: `split(quantity)`, `allocate([ratios])`
- Numeric Refinements for ergonomics: `10.dollars`, `3.euros`, `4.to_money('USD')`
- Currency registry and custom registration

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

price.to_json # => "{ "currency": "USD", "amount": "9.99" }"

# Proportional allocation and split

ten.split(3)                           #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
ten.allocate([1, 2, 3])                #=> [[USD 1.67], [USD 3.33], [USD 5.00]]

# Ranges and enumeration are supported

1.dollar..10.dollars                      #=> [USD 1.00]..[USD 10.00]
(1.dollar..3.dollars).step(1.dollar).to_a #=> [[USD 1.00], [USD 2.00], [USD 3.00]]

```

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

## Roadmap

- Improve formatting features
- Localization (I18n-aware formatting)
- `Mint.parse` for parsing human strings into money
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

On a typical machine, reference numbers are:

- Money creation: ~1.6M ops/sec
- Addition: ~1.7M ops/sec

Run locally:

```bash
# All performance suites
BENCH=true rake bench:performance

# Competitive vs money gem
BENCH=true rake bench:competitive

# Regression checks
rake bench:regression
```

## License

MIT

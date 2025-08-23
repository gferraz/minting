# Minting

Yet another Ruby library for dealing with money and currency.

[![Gem Version](https://badge.fury.io/rb/minting.svg)](https://badge.fury.io/rb/minting)

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

Option3: Install it yourself with:

```shell
gem install minting
````

## Usage

```ruby
require 'minting'

# 10.00 USD
ten_dollars = Mint.money(10, 'USD') #=> [USD 10.00]
ten_dollars.to_i            #=> 10
ten_dollars.currency_code   #=> "USD"

# Comparisons
ten_dollars = Mint.money(10, 'USD')

ten_dollars == Mint.money(10, 'USD') #=> true
ten_dollars == Mint.money(11, 'USD') #=> false
ten_dollars == Mint.money(10, 'EUR') #=> false

ten_dollars.eql? Mint.money(10, 'USD')         #=> true
ten_dollars.hash == Mint.money(10, 'USD').hash #=> true

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

price.to_json # "{"currency": "USD", "amount": "9.99"}

# Allocation and split

ten_dollars.split(3) #=> [[USD 3.34], [USD 3.33], [USD 3.33]]
ten_dollars.split(7) #=> [[USD 1.42], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43], [USD 1.43]]

ten_dollars.allocate([1, 2, 3]) #=> [[USD 1.67], [USD 3.33], [USD 5.00]]

# Numeric refinements
using Mint

1.dollar == Mint.money(1, 'USD') #=> true
3.euros == Mint.money(2, 'EUR')  #=> true
4.mint('USD') == 4.dollars #=> true
4.to_money('USD') == 4.dollars #=> true

```

## Release 1.0 Plan

- Localization: I18n
- Arithmetics: div, mod
- Mint.parse

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/gferraz/minting>.

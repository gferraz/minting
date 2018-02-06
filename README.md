# Minting

Yet another Ruby library for dealing with money and currency.

Work in progress, please wait release 1.0.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minting', git: 'https://github.com/gferraz/minting.git'
```

And then execute:

    $ bundle

Or install it yourself with:

    $ git clone https://github.com/gferraz/minting.git
    $ cd minting && gem build minting.gemspec
    $ gem install minting-0.1.2.gem

## Usage

```ruby
require 'minting'

# US dollar mint
usd = Mint.new(:USD)

# EURO mint
euro = Mint.new(:EUR)

# 10.00 USD
money = usd.money(10) #=> [USD 10.00]
money.to_i            #=> 10
money.currency_code   #=> "USD"

# Comparisons
ten_dollars = usd.money(10)

ten_dollars == usd.money(10)  #=> true
ten_dollars == usd.money(1)   #=> false
ten_dollars == euro.money(10) #=> false
ten_dollars != euro.money(10) #=> true

ten_dollars.eql? usd.money(10)         #=> true
ten_dollars.hash == usd.money(10).hash #=> true

# Format (uses Kernel.format internally)
price = usd.money(9.99)

price.to_s                                  #=> "$9.99",
price.to_s(format: '%<amount>d')            #=> "9",
price.to_s(format: '%<symbol>s%<amount>f')  #=> "$9.99",
price.to_s(format: '%<symbol>s%<amount>+f') #=> "$+9.99",
(-price).to_s(format: '%<amount>f')         #=> "-9.99",

# Format with padding
price_in_euros = euro.money(12.34)

usd.to_s(format: '--%<amount>7d')               #=> "--      9"
usd.to_s(format: '  %<amount>10f %<currency>s') #=> "        9.99 USD"
(-usd).to_s(format: '  %<amount>10f')           #=> "       -9.99"

price_in_euros.to_s(format: '%<symbol>2s%<amount>+10f')    #=> " €    +12.34"

```

## Release 1.0 Plan

- Localization: I18n, Money.to_s options: delimiter:, separator:, negative_format:, Mint::Formatter named formatters
- Arithmetics: div, mod
- Allocate
- Mint.parse

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gferraz/minting.

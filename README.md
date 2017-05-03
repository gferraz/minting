# Minting

Yet another Ruby library for dealing with money and currency.

Work in progress, please wait release 1.0.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minting'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minting

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

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gferraz/minting.

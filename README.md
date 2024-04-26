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
$ gem install minting-0.1.3.gem

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
price_in_euros = euro.money(12.34, 'EUR')

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
uning Mint

1.dollar == Mint.money(1, 'USD') #=> true
3.euros == Mint.money(2, 'EUR')  #=> true
4.mint('USD') == 4.dollars #=> true
4.to_money('USD') == 4.dollars #=> true
```

## Release 1.0 Plan

- Rails
- Localization: I18n
- Arithmetics: div, mod
- Mint.parse

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gferraz/minting.

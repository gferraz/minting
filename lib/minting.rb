# frozen_string_literal: true

require 'minting/mint'
require 'minting/version'

# By default, expose Mint::Money as the top-level Money constant for
# convenience. If Money is already defined (e.g. by the `money` gem), warn
# and skip so both libraries can coexist in the same process without
# corrupting either class.
if defined?(Money) && Money != Mint::Money
  warn "minting: top-level Money is already defined (#{Money}); skipping auto-bind. Use Mint::Money."
else
  Money = Mint::Money unless defined?(Money)
end

# frozen_string_literal: true

require 'minting/mint'
require 'minting/version'

# @!parse
#   # Top-level constant auto-bound to {Mint::Money} for convenience.
#   Money = Mint::Money

# Top-level constant auto-bound to {Mint::Money} for convenience.
#
# Set at require-time via `require 'minting'`. If {::Money} is already
# defined (e.g. by the `money` gem), a warning is emitted and the existing
# constant is preserved — use {Mint::Money} explicitly in that case.
#
# @see Mint::Money
# @note This is a **breaking change from v1.x** where both +Money+ and
#   +Currency+ required explicit opt-in via +Mint.use_top_level_constants!+.
Money = Mint::Money unless defined?(Money)

if Money != Mint::Money
  warn "minting: top-level Money is already defined (#{Money}); skipping auto-bind! Use Mint::Money."
end

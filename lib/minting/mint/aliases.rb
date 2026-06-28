# frozen_string_literal: true

# Optional top-level alias for Mint::Currency.
#
# Mint::Money is auto-bound as the top-level Money constant by
# `require 'minting'` (see lib/minting.rb). Currency is not auto-bound
# because application domain models are commonly named Currency (e.g. a
# Rails model). Require this file to opt in:
#
#   require 'minting/mint/aliases'
#
if defined?(Currency) && Currency != Mint::Currency
  warn "minting: top-level Currency is already defined (#{Currency}); skipping alias."
else
  Currency = Mint::Currency unless defined?(Currency)
end

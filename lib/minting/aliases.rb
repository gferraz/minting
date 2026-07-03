# frozen_string_literal: true

# Optional top-level alias for Money::Currency.
#
# `require 'minting'` (see lib/minting.rb). Currency is not auto-bound
# because application domain models are commonly named Currency (e.g. a
# Rails model). Require this file to opt in:
#
#   require 'minting/aliases'
#
if defined?(Currency) && Currency != Money::Currency
  warn "minting: top-level Currency is already defined (#{Currency}); skipping alias. Use Money::Currency"
else
  Currency = Money::Currency unless defined?(Currency)
end

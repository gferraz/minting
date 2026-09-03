# frozen_string_literal: true

# @!parse
#   # Top-level alias for {Mint::Currency}, opt-in via +require 'minting/aliases'+.
#   Currency = Mint::Currency

# Top-level alias for {Mint::Currency}, opt-in via +require 'minting/aliases'+.
#
# {::Currency} is **not** auto-bound by `require 'minting'` because
# application domain models are commonly named +Currency+ (e.g. a Rails
# model). Load this file explicitly to opt in.
#
# If {::Currency} is already defined, a warning is emitted and the existing
# constant is preserved — use {Mint::Currency} explicitly in that case.
#
# @see Mint::Currency

Currency = Mint::Currency unless defined?(Currency)

if Currency != Mint::Currency
  warn "minting: top-level Currency was already defined (#{Currency}); skipping alias. Use Mint::Currency"
end

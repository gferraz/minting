# frozen_string_literal: true

# @!parse
#   # Top-level alias for {Money::Currency}, opt-in via +require 'minting/aliases'+.
#   Currency = Money::Currency

# Top-level alias for {Money::Currency}, opt-in via +require 'minting/aliases'+.
#
# {::Currency} is **not** auto-bound by `require 'minting'` because
# application domain models are commonly named +Currency+ (e.g. a Rails
# model). Load this file explicitly to opt in.
#
# If {::Currency} is already defined, a warning is emitted and the existing
# constant is preserved — use {Money::Currency} explicitly in that case.
#
# @see Money::Currency
if defined?(Currency) && Currency != Money::Currency
  warn "minting: top-level Currency is already defined (#{Currency}); skipping alias. Use Money::Currency"
else
  Currency = Money::Currency unless defined?(Currency)
end

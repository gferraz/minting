# Changelog

## [Unreleased]

### New methods

- `Money.from_fractional(integer, currency)` — inverse of `#fractional`.
  Builds a `Money` from an exact Integer count of the currency's
  smallest unit (cents for USD, yen for JPY, fils for IQD, etc.).
  Accepts String, Symbol, or Currency as the currency argument.
  Raises `ArgumentError` for non-Integer input or unregistered currency.

### Documentation

- `test_readme_usage` now actually asserts the README's formatting, JSON,
  hash, `split`, and `allocate` examples instead of just exercising them
  silently. Adds 14 new assertions and protects the README from drift.
- README: corrected the `to_json` example to match the actual output
  (`{"currency": "USD", "amount": "9.99"}`).
- README: tweaked the "2x faster" headline to point at the Performance
  section, where the measured ratios live.

## [v1.3.0](https://github.com/gferraz/minting/releases/tag/v1.2.0) (2026-06-01)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.1.2...v1.2.0)

### Summary

**Breaking changes**

- Money.new is now private, use Money.create

**New methods**

- Money.create constructor
- currency.normalize_amount

**Other**
- Fix broken benchmarks
- Coercion, small improvements
- reek suggestions implemented

## [v1.2.0](https://github.com/gferraz/minting/releases/tag/v1.2.0) (2026-06-01)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.1.2...v1.2.0)

### Summary

**New methods**

- Money.to_hash
- Money.fractional
- Currency.fractional
- Mint.zero

**Other**

- Parse benchmarks added
-  Small refactoring and optimizations

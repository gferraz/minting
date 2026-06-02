# Changelog

## [Unreleased]

## [v1.4.0](https://github.com/gferraz/minting/releases/tag/v1.4.0) (2026-06-02)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.3.0...v1.4.0)



### New methods

- `Money.from_fractional(integer, currency)` — inverse of `#fractional`.
  Builds a `Money` from an exact Integer count of the currency's
  smallest unit (cents for USD, yen for JPY, fils for IQD, etc.).
  Accepts String, or Currency as the currency argument.
  Raises `ArgumentError` for non-Integer input or unregistered currency.

- `Money.clamp(min, max)` — amalogous a Numeric clamp method

### Improvements

- `Money#to_s` now validates the per-sign Hash form of `format:`.
  Empty hashes, unknown keys, and string keys raise `ArgumentError`
  with a clear message listing the valid keys (`:positive`,
  `:negative`, `:zero`). Previously these were silently ignored and
  fell through to the module default. Existing behaviour for
  partially-filled hashes is preserved.

### Breaking Changes

- Currency constructors **do not accept symbols** anymore. 
  Only String with letters and underline character ('_').

### Documentation

- `test_readme_usage` now actually asserts the README's formatting, JSON,
  hash, `split`, and `allocate` examples instead of just exercising them
  silently. Adds 14 new assertions and protects the README from drift.
- README: corrected the `to_json` example to match the actual output
  (`{"currency": "USD", "amount": "9.99"}`).
- README: tweaked the "2x faster" headline to point at the Performance
  section, where the measured ratios live.

## [v1.3.0](https://github.com/gferraz/minting/releases/tag/v1.3.0) (2026-06-01)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.2.0...v1.3.0)

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

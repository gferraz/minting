# Changelog

## [Unreleased]

### Breaking
- Money.create is now deprecated and issue an warning. Use Money.from(amount, currency)

## [v1.7.3](https://github.com/gferraz/minting/releases/tag/v1.7.3) (2026-06-15)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.7.2...v1.7.3)

### Breaking
- `Mint.currencies` deprecated

### Improvements
- Consolidate cached state into `Mint::Registry` — replaces `CurrencyRegistry` and `Mint.world_currencies` with a single module
- Thread‑safe `Registry` — `Monitor`‑guarded lazy init + copy‑on‑write for `register`, eliminates TOCTOU race on duplicate‑currency check
- Thread‑safe `Mint.zero` — delegates to `Registry.zero_for`, guarantees `assert_same` contract under concurrent access
- `Registry.currencies` now returns a frozen hash — prevents accidental mutation by callers
- Fix `Mint.zero` bug — use resolved `Currency` object as cache key instead of raw string parameter
- Restore missing YARD summary line on `Mint.register_currency`
- `Mint.currency_for_symbol(symbol)` — new public method, looks up a registered currency by its display symbol (e.g. `"$"` → USD)
- `Mint.currency_for_code(code)` — looks up a registered currency by its code
- `Registry.detect_currency(input)` — internal helper that scans strings for registered symbols, used by the parser

### Code quality
- RuboCop clean across entire project (0 offenses) — adjusted `Metrics/AbcSize`, `Metrics/ParameterLists` limits, `# :nodoc:` on reopened `module Mint`, and excluded test‑specific cops (Minitest/MultipleAssertions, ThreadSafety/NewThread, metrics)

### I18n
- `Mint.locale_backend` — class‑level accessor that accepts a callable returning locale‑aware formatting defaults (`decimal`, `thousand`, `format`)
- `Money#to_s` consults `Mint.locale_backend` when `format:`, `decimal:`, or `thousand:` are not explicitly provided
- Enables `minting-rails` (or any caller) to wire in I18n‑driven formatting without the core gem depending on `i18n`

### Tests
- Add concurrent‑access tests: `Mint.zero` singleton identity across threads, concurrent `register`, concurrent reads during registration
- Add `Registry.currencies` frozen assertion

## [v1.7.2](https://github.com/gferraz/minting/releases/tag/v1.7.2) (2026-06-15)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.7.1...v1.7.2)

### Improvements
- Parser now detects accounting-format parentheses `(USD 19.99)` and negates the parsed amount.
- Add `inspect` round-trip property test — `Mint.parse(m.inspect)` round-trips for 8 amounts × 8 currencies
- Add `Mint.zero(currency)` returning a frozen zero-Money — `Mint.zero('USD')`

### Code and Documentation
- Add benchmark regression gate (`rake bench:check`) — CI fails if core ops regress >20% vs stored baseline
- Add `test/performance/check/runner.rb` and initial `test/performance/check/results/baseline.json` for 10 core operations (creation, arithmetic, comparison, formatting, parsing, split, allocate)
- Move benchmark runner to `test/performance/check/`, baseline scoped by `RUBY_PLATFORM`
- Mark all internal methods `@private` in YARD (CoercedNumber, format helpers, parser internals, allocation helpers, clamp helpers) — 100% documented, clean public API output

## [v1.7.1](https://github.com/gferraz/minting/releases/tag/v1.7.1) (2026-06-14)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.7.0...v1.7.1)

### Fixes
- Parser now scans all uppercase words for registered currency codes instead of taking the first match. Fixes `Mint.parse("MAX 10.00 USD")` edge case where spurious non-currency words preceded the real code.

### Code and Documentation
- Add ROADMAP.md with prioritized gap list
- Update README
- Reorganize code files

## [v1.7.0](https://github.com/gferraz/minting/releases/tag/v1.7.0) (2026-06-12)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.6.2...v1.7.0)

### Fixes
- Make all tests pass in ruby 3 and 4 (required Range#step patch for ruby 3.3)
- Reorganized DSL (refinements, monkey patches, etc)

### Development and Documentation
- Add rubycritic and bundle-audit
- Add Rdoc link in README and gemspec
- 100% test coverage
- 93/100 ruby critic score on lib/**
- RDoc now available online
- Add Github CI workflow
- Drop support to ruby 3.2

## [v1.6.3](https://github.com/gferraz/minting/releases/tag/v1.6.3) (2026-06-10)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.6.2...v1.6.3)

### Improvements

- Optional top‑level access to `Money` and `Currency`

## [v1.6.2](https://github.com/gferraz/minting/releases/tag/v1.6.2) (2026-06-09)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.6.1...v1.6.2)

### Improvements

- Complement World currencies database with all ISO codes
- Fix an problem with special format option (eg: `1.23.dollars.to_s(format: "<amount> f")`)

## [v1.6.1](https://github.com/gferraz/minting/releases/tag/v1.6.1) (2026-06-08)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.6.0...v1.6.1)

### Improvements

- Benchmark files better organized

### Fixes

- Load error when initialize the gem. Fixed require in 'minting.rb'
- Fix benchmark scripts
- Fix exception name

## [v1.6.0](https://github.com/gferraz/minting/releases/tag/v1.6.0) (2026-06-08)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.5.1...v1.6.0)

### Breaking Changes

- `Mint::Money.parse` is now Mint.parse
- - No more `register_currency!` variant to register currency

### Inmprovements
- ISO 4217 currencies can be accessed by calling Mint.world_currencies

### Fixes
- `Mint.parse` should consider the underline ('_') characteralid for currency code.


## [v1.5.1](https://github.com/gferraz/minting/releases/tag/v1.5.1) (2026-06-05)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.5.0...v1.5.1)

### Fixes
- Fix 1.5.0 missing removal of Mint.zero as advertised


## [v1.5.0](https://github.com/gferraz/minting/releases/tag/v1.5.0) (2026-06-05)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.4.0...v1.5.0)

### Improvements
- Add Range and Null support to `Money#clamp(min, max` method
- Implmented exponentiation operator (**)
- Lots of Rubcop/Reek code cleanup
- Refactor Currency
  - New internal module for currency storage and YAML loading
  - Moved currencies(), currency_symbols(), load_currencies() from registry
  - Isolates class instance variables

### Breaking Changes
- `Money#same_currency?` now accepts ony `Currency` objects
- `Mint.zero` removed

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

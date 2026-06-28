# Changelog

## [Unreleased]

## [v1.9.5](https://github.com/gferraz/minting/releases/tag/v1.9.5) (2026-06-27)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.9.4...v1.9.5)

### Breaking Changes
- Now core extenssion methods, such as `"$23.34".to_money` don't require using Mint (refinements syntax) anymore.

## [v1.9.3](https://github.com/gferraz/minting/releases/tag/v1.9.3) (2026-06-26)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.9.1...v1.9.3)

### Breaking Changes
- `to_s` now works only with no paramters. to use format arguments, call `to_formatted_s` or `to_fs` 

## [v1.9.1](https://github.com/gferraz/minting/releases/tag/v1.9.1) (2026-06-26)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.9.0...v1.9.1)

### Fixes
- `Mint.parse` / `Mint::Money.parse` with an explicit `currency` parameter: the parser now scans the string for a currency code or symbol first, only falling back to the explicit parameter when none is found. Previously the explicit currency was returned immediately, ignoring any code embedded in the string.

## [v1.9.0](https://github.com/gferraz/minting/releases/tag/v1.9.0) (2026-06-23)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.8.2...v1.9.0)

### New features
- `Money::PRESETS` — frozen hash of named format presets (`:accounting`, `:european`, `:amount`, `:currency`). Pass as the first argument to `to_s` for quick access: `money.to_s(:accounting)`.
- `Money#to_s` now accepts an optional positional `preset` parameter — expands the preset and merges with any explicit kwargs.
- Validates `decimal` and `thousand` separators — rejects invalid types and identical non-empty values.

### Improvements
- `Mint.with_rounding(mode)` now loads the rounding module lazily on first call — apps that never use custom rounding modes incur zero overhead.
- `Money#subunits` — renamed from `#fractional` for clarity. `Money.from_subunits` replaces `Money.from_fraction`. **Breaking**

### Documentation
- Complete RDoc across the codebase — Money, Currency, allocation, arithmetics, clamp, coercion, conversion, and formatting modules.

### Fixes
- Fix `to_d` crash for symbols containing a '.' character.
- Fix test assertion for 0 XXX amount format.

### Performance
- `rake bench:check` now also runs benchmarks under `Mint.with_rounding(:half_down)`, storing/checking baselines for both the fast path and rounding mode in a single combined JSON file.
- `rake bench:baseline` generates baselines for both modes at once.
- `bin/bench_check` prints the best and worst ratio vs baseline per mode at the end.

## [v1.8.2](https://github.com/gferraz/minting/releases/tag/v1.8.2) (2026-06-18)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.8.1...v1.8.2)

### New methods
- `Mint::Money.no_currency(amount)` — creates a Money instance in the ISO 4217 XXX
  ("No Currency") currency. Useful for abstract monetary values, or
  placeholders where no real currency applies.

## [v1.8.1](https://github.com/gferraz/minting/releases/tag/v1.8.1) (2026-06-17)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.8.0...v1.8.1)

### Bug fixes
- Fixed `Money#to_d` crash on zero-money when calling `Integer#to_d` with a precision
  argument (incompatible with bigdecimal 4.1.2). Zero-money cache now stores a `Rational`
  instead of an `Integer`.

## [v1.8.0](https://github.com/gferraz/minting/releases/tag/v1.8.0) (2026-06-16)

[Full Changelog](https://github.com/gferraz/minting/compare/v1.7.3...v1.8.0)

### Breaking
- `Mint.zero` removed — use `Currency.zero(currency)` instead
- `Mint.currency_for_code` removed — use `Currency.for_code(code)` instead
- `Mint.currency_for_symbol` removed — use `Currency.for_symbol(symbol)` instead
- `Mint.register_currency` removed — use `Currency.register(code:, subunit:, symbol:, priority:)` instead
- `normalize_separators` renamed to `parse_separators` — returns `nil` for invalid input instead of raising
- `parse_currency` signature changed to `(input, currency = nil)` — returns `nil` when currency cannot be determined
- `Mint.parse` now returns `nil` on failure instead of raising. Use `Mint.parse!` for the raising variant.

### Improvements
- `Mint.with_rounding(mode)` — block-scoped rounding mode via `Thread.current`, restores on exit
- `Currency#normalize_amount` delegates to `Mint::Rounding.apply` — single dispatch point for all rounding
- `allocate` and `split` use `currency.normalize_amount` instead of direct `.round(subunit)` — automatically respect block-scoped mode
- Modes: `:half_up`, `:half_down`, `:floor`, `:ceil`, `:truncate`, `:down` — all `Rational`-native, no `BigDecimal` dependency
- `Currency.zero(currency)` — class method on `Currency`, new home for zero-money access
- `Currency.for_code(code)` — direct hash lookup by currency code
- `Currency.for_symbol(symbol)` — exact symbol match via frozen hash
- `Currency.register(code:, subunit:, symbol:, priority:)` — idempotent registration on the `Currency` class
- `Currency#zero` — instance shortcut to `Registry.zero_for(self)`, used internally by `Money.from`, `Money.from_fractional`, and `Money#copy_with`
- `Money.zero(currency)` — class method delegating to `Currency.zero`
- `Money#copy_with(amount:)` — renamed from `Money#change` for immutability semantics; `Money#mint` retained with deprecation warning
- `Mint.parse!` — raising variant of `Mint.parse`
- `Money.parse` / `Money.parse!` — thin wrappers on `Mint.parse` / `Mint.parse!`
- `Mint.locale_backend` extracted to `lib/minting/mint/locale_backend.rb`
- `parse_separators` returns `nil` for invalid patterns instead of raising — consistent nil-propagating pattern with `Mint.parse`

### Code quality
- ROADMAP reorganized — completed items moved below pending, P2-A lowered to Low, P1-5 marked done, suggested next steps updated
- Methods reorganized — arithmetic, constructors, and coercion moved to dedicated modules for clarity
- Benchmark files updated to use new `Currency.*` and `copy_with` API
- README.md updated for renamed methods (`Currency.register`, `Currency.zero`)
- `.github/copilot-instructions.md` updated for `Currency.register`
- RDoc and inline documentation updated across the codebase
- Copilot instructions moved to `doc/agents/`

### Tests
- Add `Mint::Money.zero(currency)` delegation tests
- Test names and calls updated for `Money#copy_with`

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
- Add `Mint::Money.zero(currency)` delegation tests

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

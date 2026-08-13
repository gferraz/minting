# API Review — 2026-08-13

## Scope

This review covers the public money, currency, parsing, formatting, allocation,
and serialization APIs in Minting 2.1.1. The full test suite, RuboCop, the
Ruby 4 benchmark regression gate, and `bundle-audit` were run during review.

## Validation snapshot

- Tests: 224 runs, 751 assertions, no failures or errors.
- Coverage: 94.56% line coverage.
- RuboCop: 33 files inspected, no offenses.
- Benchmark regression gate: passed on Ruby 4.0.6.
- Dependency audit: no known vulnerabilities found.

## Strengths

- `Mint::Money` and `Mint::Currency` are immutable value objects. Amounts are
  represented as `Rational`, avoiding floating-point drift.
- Currency registration uses a mutex and copy-on-write frozen hashes, which is
  a clear and appropriate concurrency model for shared registry state.
- The public contracts around zero-money caching, strict `eql?`/`hash`, and
  cross-currency comparison are well considered and covered by tests.
- Allocation and split preserve the total amount after subunit rounding.
- Formatting has a flexible template API, sign-specific formats, locale hooks,
  and measured performance coverage.

## Findings and recommendations

## Follow-up status — 2026-08-13

The first three findings below have been implemented after this review:

- **P1 parser hardening:** `Money.parse` now rejects malformed numeric input
  by returning `nil`, and `Money.parse!` raises `ArgumentError`. Regression
  tests cover malformed forms and the numeric validation grammar.
- **P2 formatter cache:** compiled formatters are stored in a thread-safe,
  copy-on-write cache capped at 256 configurations. Once full, new
  configurations are compiled without being retained.
- **P2 generated invariants:** deterministic generated tests cover split and
  allocation conservation, subunit round trips, supported format/parse round
  trips, and malformed parsing.

The original findings are retained below as historical context.

### Resolved P1 — Make `Money.parse` reject malformed input reliably

`Money.parse` documents a nil-returning contract for invalid input, but the
current parser can both accept malformed text and leak `ArgumentError`.

Examples with an explicit USD currency:

```ruby
Money.parse('abc1def2', 'USD') # => [USD 12.00]
Money.parse('USD12oops', 'USD') # => [USD 12.00]
Money.parse('1.2.3', 'USD') # => [USD 123.00]
Money.parse('1--2', 'USD') # raises ArgumentError
Money.parse('--1', 'USD') # raises ArgumentError
```

The behaviour originates in `parse_amount`, which removes every character
other than digits, decimal/thousands separators, and minus signs before
calling `Rational`.

Recommended change:

1. Define an explicit grammar for the numeric portion, including an optional
   leading sign, valid separator placement, and accounting parentheses.
2. Have `Money.parse` convert invalid numeric syntax to `nil` consistently.
3. Keep `Money.parse!` as the raising counterpart, but raise a controlled
   `ArgumentError` with the original input rather than allowing `Rational`'s
   implementation exception through.
4. Add regression tests for every example above and property-based malformed
   input tests.

Relevant implementation: `lib/minting/money/parse.rb`.

### Resolved P2 — Bound the formatter cache

`Money::Formatter.cache` is an unbounded class-level hash keyed by template
and separator values. Since `Money#format` accepts arbitrary caller-provided
templates, a long-running process can retain a new compiled formatter for each
unique input.

Recommended change:

- Cache only fixed presets, or use a bounded LRU cache for dynamic templates.
- Document that dynamic formatting templates must be application-controlled.
- Establish an explicit synchronization policy if formatters may be compiled
  concurrently.

Relevant implementation: `lib/minting/money/format/formatter.rb`.

### Resolved P2 — Add invariant and generative tests

The existing example-driven test suite is strong. Financial logic would benefit
from generated inputs to protect its key invariants across signs, subunit
precisions, and large values.

Suggested invariants:

- `money.split(n).sum == money` for every positive integer `n`.
- `money.allocate(ratios).sum == money` for valid ratio arrays.
- `Money.from_subunits(money.subunits, currency) == money`.
- Parsing invalid input never raises from `Money.parse`.
- Formatting and parsing round-trip for explicitly supported formats.

### P3 — Publish RBS signatures

RBS definitions would make the public API easier to use safely in Ruby
applications. They are especially valuable for methods that accept multiple
input forms, such as currency resolution, constructors, comparisons,
formatting, and parsing.

Start with `Mint::Money`, `Mint::Currency`, `Mint`, and the numeric/string
refinements; then add Steep or TypeProf validation in CI.

### P4 — Keep maintenance documentation current

`doc/agents/AGENTS.md` still describes removed `Mint.parse` and
`Mint.with_rounding` APIs and parser paths that no longer exist. The public
API now uses `Money.parse` and the current implementation is under
`lib/minting/money/parse.rb`.

Update this document alongside public API changes so future maintenance work
is based on the implementation that is actually shipped.

### P5 — Add public project-health files

For a public gem, add a short `SECURITY.md` with a vulnerability reporting
channel and supported-version policy. A `CODE_OF_CONDUCT.md` can follow if
community contributions become a focus.

## Suggested sequence

1. Introduce RBS gradually, starting with core public classes.
2. Keep README and active maintenance guidance synchronized with API changes.
3. Add public project-health files.

## No source changes in this review

This document records review findings only. It does not change public API
behaviour.

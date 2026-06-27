# `minting` — Recommendations Roadmap

Living document of improvement recommendations for the `minting` gem,
produced from a full read of `AGENTS.md`, `README.md`, `CHANGELOG.md`,
and the entire `lib/` + `test/` tree (v1.3.0 baseline).

**Conventions**

- P0 / P1 / P2 / P3 = priority. P0 = small, high-value, ship now.
- ✅ = done (committed on `master` or an in-flight branch).
- 🟡 = partially done.
- Each item is sized to be a single PR unless marked *[epic]*.
- File references are relative to repo root.

---

## TL;DR

The gem is in **excellent shape**: ~1,400 LoC, 100% line coverage,
RuboCop + Reek clean, performance bench suite, immutable `Rational`
internals, 117 built-in currencies. The recommendations below are
**polish, hardening, and roadmap** — not "fix the broken thing".

Two of the highest-leverage moves are already in flight:

- ✅ **README-as-spec** — `test_readme_usage` now asserts the
  README's `to_s` / `to_json` / `to_hash` / `split` / `allocate`
  examples instead of just exercising them silently.
- ✅ **`Money.from_fractional`** — symmetric inverse of `#fractional`
  with full test + README + CHANGELOG coverage.

The remaining work is mostly documentation discipline, API ergonomics,
and the two roadmap items already advertised in the README (I18n +
exchange rates).

---

## 🔴 P0 — Quick wins, ship now

### P0-1 ✅ Tighten README-as-spec

**Status:** Merged in commit `20359dc`.

- Turned 14 commented `#=>` examples in `test/minting_test.rb` into
  real `assert_equal` calls.
- Fixed typo: `conversiob` → `conversion`.
- Corrected the README's `to_json` example to match the actual output
  (the real string has spaces around the `:`).
- Softened the "2× faster" headline to point at the Performance
  section where the measured ratios live.
- Added a one-line `rubocop:disable` on `test_readme_usage` (the spec
  has to stay monolithic to serve as a spec).

**Why it mattered:** the test was passing while the README silently
drifted. Now any example change in the README either stays correct or
fails CI.

### P0-2 🟡 Auto-require `bigdecimal` and clean up `to_d`

**Status:** Partial — the dependency was added in commit `33b2c01`
(`s.add_dependency 'bigdecimal', '>= 4.0'` in `minting.gemspec`).
The runtime guard in `lib/minting/money/conversion.rb` (lines 10–14)
is now redundant:

```ruby
def to_d
  raise NoMethodError, 'decimal gem required' unless defined?(BigDecimal)
  amount.to_d 0
end
```

**Follow-up:** delete the `raise NoMethodError` line. It's dead code
once `bigdecimal` is a hard dependency. One-line PR.

### P0-3 ✅ Fix CHANGELOG typos

**Status:** Done in commit `20359dc` — "is no private" →
"is now private" in the v1.3.0 entry. Watch for new typos as
items are added under `[Unreleased]`.

### P0-4 Add a CI gate on the marketing claims

The README's "**2× faster**" / "**10×+ for formatting**" headline and
the table at the bottom (lines 213–247) are generated from a single
Qwen run on 2026-05-30 and aren't reproducible from CI.

**Concrete action:** in CI, run

```sh
ake bench:regression
```

and fail the build if any benchmark regresses by more than (e.g.)
20% vs the stored baseline in `pkg/bench_baseline.json`. The baseline
file is optional but easy to maintain.

This makes the table *defensible* rather than aspirational.

---

## 🟠 P1 — Correctness, clarity, small ergonomics

### P1-1 🟡 `Money.from_fractional(integer, currency)`

**Status:** Merged on branch `feature/money-from-fractional` (commit
`150a2d0`).

- Inverse of `#fractional`. Uses `Rational(n, fractional_multiplier)`
  so subunit-0 currencies work without a special case.
- Integer-only contract — rejects `Float` / `String` / `Rational` with
  `ArgumentError` to preserve the exactness guarantee.
- Accepts `String`, `Symbol`, or `Currency` for the currency arg,
  matching `Mint.money` / `Money.create`.
- 4 new tests + 3 new README-spec asserts; 100% coverage maintained.

**To do** Add benchmark tests

### P1-2 Add `Money#clamp(min, max)`, `Money#min(other)`, `Money#max(other)`

`Comparable` is already mixed in (`lib/minting/money/comparable.rb`),
so `min` and `max` work *implicitly* through the `<=>` machinery —
but only when both operands are the same currency. A first-class
`#clamp` would be a one-liner and very useful in domain code
(pricing floors/ceilings, exchange-rate bands, etc.).

```ruby
# Sketch
def clamp(min, max)
  raise ArgumentError, 'min/max must share currency' unless
    same_currency?(min) && same_currency?(max)
  return min if self < min
  return max if self > max
  self
end
```

Add tests for: in-range, below-min, above-max, equal-to-bound,
non-matching-currency error.

### P1-3 Improve `to_s` format-hash handling

`lib/minting/money/formatting.rb` accepts `format:` as either a
`String` or a `Hash` with `:positive` / `:negative` / `:zero` keys.
The current code:

- Falls through to `'%<symbol>s%<amount>f'` if `:positive` is missing
  and the input is non-zero non-negative (line 58).
- Has no test coverage for the hash form at all.

**Action:** add explicit tests for:

- `{ positive: '...', negative: '...', zero: '...' }`
- `{ positive: '...' }` alone (default for neg/zero)
- Mixing hash and `decimal:` / `thousand:` kwargs

### P1-4 Document and harden registry thread-safety

`lib/minting/mint/registry.rb` memoizes `@currencies`,
`@currency_symbols`, and `@zero` with `||=`. In a multi-threaded
server (Rails, Sidekiq, Puma) the first call to `Mint.money` from
two threads can:

- Both call `YAML.load_file` and `register` the same currencies.
- Both call `@currency_symbols ||= ...` and produce a non-frozen copy
  that diverges.

**Action:** either

1. Wrap the lazy initializers in `Mutex#synchronize` (3 places), or
2. Switch to `Concurrent::Map` (no new dep), or
3. Eager-load in a Railtie/loaded hook and treat the registry as
   read-only after boot.

Option 3 is the most pragmatic. Document the contract.

### P1-5 Make `Mint.currencies` immutable

`currencies` returns the live `@currencies` hash. A caller can
`currencies.delete('USD')` and break invariants. Either:

- Return a frozen copy (`@currencies.dup.freeze`), or
- Document loudly that the returned hash must be treated read-only.

### P1-6 Improve `coercion.rb` — add `**` and a clean `==`

`lib/minting/money/coercion.rb` defines `CoercedNumber` (used by
`Money#coerce`) with `+`, `-`, `*`, `/`, `<=>`, but no `**` or `==`.

```ruby
2 ** 0.dollars   #=> 1  (works)
2 ** 5.dollars   #=> NoMethodError  (silent failure)
```

`==` falls through to `Comparable`, which raises `ArgumentError`, but
a custom `==` on `CoercedNumber` would give a more specific error
message.

**Action:** add `**` and `==` to `CoercedNumber`. Tests in
`test/money/money_coercion_test.rb` (or wherever they live).

### P1-7 Add `inspect` round-trip test

`Money#inspect` is implemented in `lib/minting/money/money.rb:79`
as `"[#{currency_code} %0.#{currency.subunit}f]"` — e.g.
`[USD 9.99]`. The existing parser (`lib/minting/money/parse.rb`)
can almost read this back, but a clean round-trip would be a nice
property test:

```ruby
m = Mint.money(9.99, 'USD')
assert_equal m, Mint.parse(m.inspect.delete_prefix('[').delete_suffix(']'))
```

Make it a one-liner or a property-based test with 10–20 random
amounts. Cheap, catches regressions in either direction.

---

## 🟡 P2 — Roadmap items already advertised in README

### P2-1 I18n / locale-aware formatting *[epic]*

Foundation is already there: `to_s(decimal: ',', thousand: '.')`
works. What's missing is locale-keyed defaults:

```ruby
Mint.money(9.99, 'USD').to_s(locale: :'pt-BR') #=> "US$ 9,99"
Mint.money(9.99, 'USD').to_s(locale: :'fr')    #=> "9,99 $US"
```

**Action plan (multi-PR):**

1. Add `Mint::Locale` value object + a small `locales.yaml` (or
   build off `currencies.yaml` since most formatting info is per-
   currency already).
2. Add `I18n` integration behind a `require 'minting/i18n'` opt-in.
3. Default to "no locale" so existing code is unaffected.

### P2-2 Exchange rates *[epic]*

Mentioned in the README Roadmap. The hard part isn't the math, it's
the rate source. Suggested shape:

```ruby
Mint.bank = Mint::Bank::MemoryStore.new(
  'USD' => { 'EUR' => 0.92, 'JPY' => 149.50 }
)
Mint.money(10, 'USD').exchange('EUR') #=> [EUR 9.20]
```

Multi-PR epic:

1. `Mint::Bank` interface with `#exchange(money, target)`.
2. `Mint::Bank::MemoryStore` (in-memory, good for tests).
3. `Mint::Bank::ECB` or `Mint::Bank::OpenExchangeRates` (network).
4. Update `attribute-money` to expose bank config in the Railtie.

### P2-3 Reek / RuboCop tightening

`.rubocop_todo.yml` still has 9 pre-existing offenses, all in
`test/performance/*` and `test/mint_benchmark.rb`. They're
"`Metrics::BlockLength`" / "`Metrics::MethodLength`" — fixable by
extracting helper methods or by scoping the cop to non-bench code.

---

## 🟢 P3 — Polish

### P3-1 ✅ Move AI-generated docs to `doc/agents/`

Done in commit `ff08578`. Consider also moving `pkg/` artifacts to
a release script that builds on tag rather than committing pre-built
gems.

### P3-2 `Gemfile.lock` policy

`Gemfile.lock` is currently committed. The project is a *gem*, not
an app, so the conventional choice is to *not* commit it (let
consumers' Bundler resolve). Or, if you prefer reproducibility for
CI, commit it and document the choice in `CONTRIBUTING.md`.

### P3-3 Add `SECURITY.md` and `CODE_OF_CONDUCT.md`

Standard hygiene for a public Ruby gem. One PR each, copy-paste
from the GitHub templates.

### P3-4 Document `Money#each_currency` / `Mint.currencies.each_value`

The README's "Features" list doesn't mention that you can iterate
registered currencies. Trivial doc addition; potential ergonomic
win for tooling authors.

### P3-5 Decide on `pkg/` retention

`pkg/minting-*.gem` is in `.gitignore`, but old builds may still
sit there. Run `rake clobber_pkg` (if it exists) or just `rm -rf
pkg/*` once. Then add a `git clean -nd pkg` check to `Rakefile` if
you want belt-and-braces.

---

## Suggested next PR (after `from_fractional` merges)

**Title:** *Delete dead `to_d` guard, document `bigdecimal` as a hard dependency*

**Scope:**

- `lib/minting/money/conversion.rb`: remove
  `raise NoMethodError, 'decimal gem required' unless defined?(BigDecimal)`.
- `CHANGELOG.md`: add a one-liner under `[Unreleased]` → `### Other`.
- `test/money/money_conversion_test.rb`: add a sanity test that
  `to_d` returns a `BigDecimal` (already covered indirectly, but
  make it explicit).

One-line source change, one-line test, one-line changelog. ~10 min.

---

## Metrics to watch going forward

| Metric | Current | Target |
|---|---|---|
| Line coverage | 100% (284/284) | ≥ 100% — don't regress |
| Test count | 80 runs, 342 assertions | Grow with each new method |
| `to_s` Hash format coverage | 0 tests | ≥ 6 (P1-3) |
| Bench variance vs baseline | unmeasured | ≤ 20% (P0-4) |
| Public API methods with YARD | ~all | 100% (already achieved) |
| Open `rubocop_todo` offenses | 9 in `test/performance/*` | 0 (P2-3) |
| `Gemfile.lock` policy | committed | documented (P3-2) |
| `to_d` runtime guard | present but dead | removed (suggested next PR) |

---

*Last updated alongside PR #2 (`Money.from_fractional`). Refresh
after each release.*

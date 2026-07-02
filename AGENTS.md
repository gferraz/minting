# AGENTS.md

Guidance for AI coding agents working in the `minting` Ruby gem.

## Project

`minting` is a money-handling gem for Ruby (>= 3.3). Amounts are stored as
`Rational` and rounded to the currency subunit — no floating-point anywhere.
The gem is namespaced under `Mint`; top-level `Money`/`Currency` are an
opt-in alias (see below).

## Essential commands

```bash
bundle install                          # install deps (dev deps include benchmark, reek, rubocop, rubycritic, yard)

bundle exec rake                        # default task = :test (full unit suite + SimpleCov)
bundle exec rake test                   # unit tests only
bundle exec rake cop                    # RuboCop on lib/ (plugins: minitest, packaging, performance, rake, thread_safety)
bundle exec rake critic                 # RubyCritic (min score 70, output tmp/rubycritic)
bundle exec rake yard                   # YARD docs for lib/**/*.rb
bundle exec rake bundle:audit           # bundler-audit (CI runs this)

gem build minting.gemspec               # build .gem package
bin/console                             # IRB with bundler/setup and minting loaded

# Single test file (fast iteration — recommended over `rake` for one change):
ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb

# Single test method (Minitest -n is a regexp):
ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb -n /test_amount/
```

The test_helper requires SimpleCov (writes to `tmp/simplecov`) and minitest.
Always pass `-r ./test/test_helper.rb` when running files directly, otherwise
coverage and minitest/autorun won't be loaded.

### Performance / benchmarks

Benchmarks are Minitest-based (require `benchmark/ips`) and live under
`bench/`. The CI gate is `rake bench:check`, which compares core
ops against `bench/check/results/baseline-<platform>.json`.

```bash
bundle exec rake bench:all                # core + memory + regression + competitive/money
bundle exec rake bench:core
bundle exec rake bench:memory
bundle exec rake bench:regression
bundle exec rake bench:check              # CI gate — fails if ops drop below 0.80x of baseline
bundle exec rake bench:baseline           # regenerate the platform baseline (run before committing a perf improvement)
bundle exec rake bench:competitive        # Minting vs the `money` gem (needs `money` group installed)
bundle exec rake bench:competitive:shopify# vs `shopify-money` (uses BUNDLE_WITHOUT=money_bench)
bundle exec rake bench:competitive:all    # both
```

Notes:
- `bench:check` runs `bin/bench_check`, which shells out to
  `bench/check/runner.rb`. The runner **exits early on Ruby < 4.x**
  with a no-op result — the gate only meaningfully runs on Ruby 4.0+.
- Competitive Shopify benches set `BUNDLE_WITHOUT=money_bench` to avoid
  loading both `money` and `shopify-money` together.
- The `money` and `shopify-money` gems are in optional Bundler groups
  (`money_bench`, `shopify_bench`) and are **not** installed by a plain
  `bundle install`. Use `bundle install --with money_bench` if you need the
  Money-gem comparison.

### CI

`.github/workflows/ci.yml` runs on Ruby 3.3 and 4.0:
`rake cop`, `rake test`, `rake bench:check`, `rake bundle:audit`.

## Architecture

### Load graph

`lib/minting.rb` requires `minting/mint` and `minting/version`, then auto-binds
`::Money = Mint::Money` (warn-and-skip if already defined).
`lib/minting/mint.rb` wires the rest: `Currency`, the DSL refinements
(`mint/dsl/numeric`, `range`, `string`), `i18n`, `Mint` module, parser +
separators, registry, and finally `money/money` (which itself requires all
`money/*` mixins).

### Top-level constants: `Money` auto-bound, `Currency` opt-in

`require 'minting'` auto-binds the top-level `Money` constant to `Mint::Money`
for convenience. If `::Money` is already defined (e.g. the `money` gem loaded
first), it warns and skips — use `Mint::Money` in that case. This is a
**breaking change from < v2.0**, where both constants were opt-in via
`Mint.use_top_level_constants!` (now removed).

`Currency` is **not** auto-bound, because application domain models are
commonly named `Currency` (e.g. a Rails model). Opt in via
`require 'minting/mint/aliases'`, which binds `Currency = Mint::Currency`
with the same warn-and-skip guard.

There is **no `lib/minting/dsl.rb`** and **no `Mint.use_top_level_constants!`**
(removed in v2.0). The only opt-in path for `Currency` is
`require 'minting/mint/aliases'`.

### Two namespaces, one registry

- `Mint::Currency` — a `Data.define` value object (`code`, `subunit`,
  `symbol`, `priority`, `country`, `name`, `fractional_multiplier`).
  Immutable. Constructed via `Currency.new(...)` or `Currency.register(...)`.
- `Mint::Money` — an immutable value object (frozen on `initialize`) holding
  a `Rational` amount and a `Currency`. All behavior is split into mixins
  required by `money/money.rb`: `arithmetics/`, `format/`, `allocation/`,
  `clamp`, `coercion`, `comparable`, `constructors`, `conversion`.
- `Mint::Registry` — the only place with mutable shared state. Holds
  `@currencies` (frozen hash), `@world_currencies` (frozen, from
  `data/world-currencies.yaml`), `@currency_symbols` /
  `@currency_symbol_map`, and `@zeros` (cached frozen zero-Money per
  currency). All access is guarded by `Mint::Registry::MUTEX` (a `Monitor`).
  Currencies hash is replaced (not mutated) on `register` — never do
  `Registry.currencies.delete(...)`; you'll get a frozen-hash error.

### Currency resolution

`Currency.resolve(obj)` accepts `nil`, `Currency`, `Money`, or `String` and
returns `nil` on miss; `Currency.resolve!(obj)` raises `Mint::UnknownCurrency`.
`Mint::UnknownCurrency < ArgumentError`, so existing `rescue ArgumentError`
handlers still work — new code can `rescue Mint::UnknownCurrency` for the
specific case. `Mint.money` and `Money.from` always go through `resolve!`, so
unknown codes raise rather than returning nil. `Money.from` also short-circuits
zero amounts to the cached `currency.zero` singleton, so
`Mint.money(0, 'USD')` is the same frozen object across calls — don't assume
`Money.new` is the only path.

### Amount normalization

`Currency#normalize_amount(amount)` = `amount.to_r.round(subunit)`. This is
the single funnel for construction, parsing, `copy_with`, `allocate`, and
`split`. The default fast path is `Rational#round` (half-up).

`Mint.with_rounding(mode)` is **lazy-loaded**: the first call requires
`mint/rounding`, which `remove_method`s `normalize_amount` and redefines it
to dispatch through `Mint::Rounding.apply`. This adds ~10–35ns per
money creation/mutation from then on. The fast path is restored only by
process restart, not by leaving the `with_rounding` block — the block just
restores the *thread-local mode* (`Thread.current[:minting_rounding_mode]`),
not the patched method. Mode is thread-local; the patch is global. Supported
modes: `:half_up`, `:half_down`, `:floor`, `:ceil`, `:truncate`, `:down`
(`:down` is an alias for `:truncate`).

### Parser

`Mint.parse` / `Mint.parse!` live on the `Mint` module itself
(`mint/parser/parser.rb`, `mint/parser/separators.rb`) via `extend self`.
`Mint::Money.parse` delegates to `Mint.parse`.

Currency detection order in `parse_currency`:
1. Scan all uppercase `\b[A-Z_]+\b` words, return the first registered code.
   This intentionally skips non-currency uppercase words (`"MAX 10.00 USD"`
   → USD).
2. Fall back to `Registry.detect_currency(input)` — scans for registered
   symbols, longest symbol first, then by `currency.priority` desc.
3. Fall back to the explicit `currency` argument (resolved via
   `Currency.resolve`).

So an explicit currency arg is a **fallback**, not an override — if the
string contains a code/symbol, that wins. This changed in v1.9.1; the test
`test_parse_with_explicit_currency` in `money/money_parse_test.rb` pins the
behavior (e.g. `parse('19.99 BRL', 'USD')` → BRL, not USD).

Separator classification (`classify_separators`) is positional, not
locale-aware: `1,234` → thousands comma (because comma is at position -4),
`19,99` → decimal comma, `1.234,56` → mixed (rightmost separator is
decimal). Accounting negatives (`($1.23)`) are detected by `(` prefix and `)`
suffix and negate the amount.

### Formatting

`Money#to_formatted_s(preset = nil, format:, decimal:, thousand:, width:)`
is the core; `to_s` and `to_fs` are aliases with no args. As of v1.9.3,
`to_s` **takes no arguments** — pass format args to `to_formatted_s` /
`to_fs`. The README examples using `money.to_s(format: ...)` are out of date
for v1.9.3+; use `to_formatted_s` or `to_fs` in new code and tests.

Format strings use `Kernel.format` named-reference syntax:
`%<symbol>s`, `%<amount>f`, `%<amount>d`, `%<currency>s`, `%<integral>d`,
`%<fractional>d`. The `%<amount>f` specifier has the currency's subunit
precision **injected at runtime** (e.g. `%<amount>f` → `%<amount>.2f` for
USD) by a gsub in `format/formatting.rb`. For zero-subunit currencies (JPY),
`%<fractional>d` specifiers are stripped entirely.

`format` can also be a Hash with `:positive`, `:negative`, `:zero` keys for
per-sign templates (used by the `:accounting` preset). Missing keys fall back
to `%<symbol>s%<amount>f`; unknown keys raise `ArgumentError`.

Named presets (`Money::PRESETS`): `:amount`, `:accounting`, `:european`,
`:currency`. Passing a preset as the first arg expands it; explicit kwargs
override the preset.

`Mint.locale_backend=` (a callable or Hash returning
`{ decimal:, thousand:, format: }`) supplies defaults when the corresponding
kwarg is nil. This is how `attribute-money` wires I18n. See
`test/locale_backend_test.rb` — tests save/restore the backend in
setup/teardown; do the same if you touch it.

### Equality semantics — read this before touching `comparable.rb`

Two distinct notions of equality:
- `==` (loose): `0 == money` iff `money.zero?` (any currency). Two Moneys
  are `==` iff same amount AND same currency. Non-zero numerics are never
  `==` to Money.
- `eql?` / `hash` (strict, for Hash lookup): `eql?` requires both amount and
  currency to match exactly — **zero is NOT cross-currency equal under
  `eql?`**. `hash = [amount, currency_code].hash`.

So `Mint.money(0,'USD') == Mint.money(0,'EUR')` is true, but `.eql?` is
false and their hashes differ. The `<=>` operator raises `TypeError` when
comparing non-zero Moneys of different currencies, and when comparing a
non-zero Money to a non-zero Numeric. Only `0` is comparable to Money across
the numeric boundary.

`CoercedNumber` (private, in `coercion.rb`) makes `5 * money` work but
raises on `5 + money` unless `5` is zero, and raises on `numeric / money`
entirely (no meaningful currency for the result).

### Allocation and split

`split(n)` and `allocate(ratios)` both round each part to the subunit, then
distribute the residual (`amount - parts.sum`) by adding/subtracting
`currency.minimum_amount` to the **first** N slots (N = leftover / minimum).
This means the first slots carry the rounding error — documented behavior,
pinned by tests. `allocate_left_over` mutates the `amounts` array in place.

### DSL / refinements

`Mint` refines `Numeric` (`10.dollars`, `10.reais`, `10.euros`,
`n.to_money(currency)`) and `String` (`'19.99'.to_money('USD')` — note this
calls `to_r` on the string, it does **not** run the full parser, so symbols
and codes in the string are ignored). Refinements require `using Mint` in
the scope; tests typically put `using Mint` at the top of the test class.

`Range#step` with a `Money` step is patched via `Range.prepend(
Mint::RangeStepPatch)` **only on Ruby < 4.0** (`mint/dsl/range.rb`). Ruby 4.0+
handles non-numeric steps natively, so the patch is gated by
`RUBY_VERSION < '4.0'`.

## Conventions

- `# frozen_string_literal: true` magic comment in every file.
- Ruby 3.3+ syntax is used freely: endless methods (`def foo = ...`), pattern
  matching (`in`/`case in`), `Data.define`, anonymous splat/block forwarding
  (`&`).
- YARD docstrings on public API; `@api private` for internal methods;
  `# :nodoc:` on internal class/module containers.
- Currency codes must match `/^[A-Z_]+$/` (enforced in `Registry.register`).
  Custom codes with underscores are allowed (the test suite registers
  `BRL_FUEL`).
- RuboCop line length max 120. `Metrics/AbcSize` max 25, `MethodLength` max
  30, `ParameterLists` max 6, `CyclomaticComplexity` max 11. Several cops
  are disabled in test files (see `.rubocop.yml`).
- `ThreadSafety/ClassInstanceVariable` and
  `ThreadSafety/ClassAndModuleAttributes` are **disabled** — the registry
  legitimately uses class instance vars guarded by a `Monitor`. Don't
  "fix" those warnings by removing the mutex.
- `Naming/BinaryOperatorParameterName` and `Style/NumericPredicate` are
  disabled.

## Tests

- Minitest, no RSpec. Test classes subclass `Minitest::Test`; benchmarks
  subclass `Minitest::Benchmark`.
- `test/minting_test.rb#test_readme_usage` exercises README examples — if you
  change README code or core behavior, keep this test in sync. It's the
  contract between the README and the implementation.
- `using Mint` at the top of a test file enables the refinements for all
  tests in that file.
- Tests register custom currencies (e.g. `BRL_FUEL` in `money_format_test.rb`)
  at class-load time. `Registry.register` raises on duplicate codes, so if a
  prior test file already registered the same code you'll get a failure —
  reuse existing custom codes rather than registering new ones in multiple
  files.
- Locale tests (`locale_backend_test.rb`) save and restore
  `Mint.locale_backend` in setup/teardown. Always restore global state.

## Gotchas

- **`to_s` takes no args since v1.9.3.** Use `to_formatted_s` (or `to_fs`)
  for format/decimal/thousand/width. Calling `to_s(format: ...)` raises
  `ArgumentError: wrong number of arguments`.
- **`Money` is auto-bound at require time.** `require 'minting'` sets
  `::Money = Mint::Money`. If `::Money` is already defined (e.g. the `money`
  gem loaded first), it warns and skips. `Currency` is **not** auto-bound —
  use `require 'minting/mint/aliases'` to opt in. There is no
  `Mint.use_top_level_constants!` (removed in v2.0) and no `lib/minting/dsl.rb`.
- **Money-gem co-loading requires order.** If both minting and the `money`
  gem are loaded in the same process (e.g. competitive benchmarks),
  `require 'money'` must run **before** `require 'minting'` — otherwise the
  money gem's `class Money` reopens and corrupts `Mint::Money`'s methods.
  The competitive benchmark helpers (`competitive/money/benchmark_helper.rb`,
  `competitive/shopify/benchmark_helper.rb`) require `money_setup`/
  `shopify_setup` before `benchmark_helper` for this reason.
- **Zero singleton.** `Mint.money(0, 'USD')` returns the cached frozen
  `currency.zero`, not a fresh object. `Money.from` and `Money.from_subunits`
  both do this. Equality and `assert_same` tests rely on it.
- **`Rounding` patch is global and permanent.** Once `Mint.with_rounding` is
  called, `Currency#normalize_amount` is patched for the rest of the process.
  The block only restores the thread-local mode, not the method. The fast
  path (`amount.to_r.round(subunit)`) is gone after the first call.
- **`String#to_money` is not the parser.** `'19.99'.to_money('USD')` uses
  `String#to_r`, so `'$19.99'.to_money('USD')` raises. Use `Mint.parse` for
  symbol/code-aware parsing.
- **`Registry.currencies` is frozen.** Mutating it raises. `register`
  rebuilds the hash via `merge` and freezes the new one.
- **Competitive benchmark groups.** `money` and `shopify-money` are in
  optional Bundler groups; plain `bundle install` won't pull them. Shopify
  benches run with `BUNDLE_WITHOUT=money_bench` to avoid both loading at
  once.
- **`bench:check` is Ruby-4-only.** The runner no-ops on Ruby < 4.x. CI runs
  it on both 3.3 and 4.0, but it only meaningfully gates on 4.0.
- **CI Ruby versions:** 3.3 and 4.0. `.tool-versions` pins 4.0.5 for local
  dev. The `Range#step` Money patch is only active on < 4.0, so behavior
  differs across the matrix for that one feature.

## Key files

| Path | What |
|------|------|
| `lib/minting.rb` | entry point (requires `mint/mint`, `version`) |
| `lib/minting/mint.rb` | load graph for Mint, Currency, registry, parser, DSL |
| `lib/minting/mint/mint.rb` | `Mint.money`, `Mint.with_rounding`, `Mint::UnknownCurrency` (`< ArgumentError`, raised by `Currency.resolve!`) |
| `lib/minting/mint/registry/` | `registry.rb`, `registration.rb`, `symbols.rb`, `zeros.rb` — all shared state + `MUTEX` |
| `lib/minting/currency/currency.rb` | `Currency` (`Data.define`), `resolve`/`resolve!`/`register`/`for_code`/`for_symbol`/`zero` |
| `lib/minting/mint/parser/parser.rb`, `separators.rb` | `Mint.parse` / `Mint.parse!` |
| `lib/minting/mint/rounding.rb` | lazy rounding-mode module + global `normalize_amount` patch |
| `lib/minting/mint/i18n.rb` | `Mint.locale_backend` + `resolve_locale_for` |
| `lib/minting/mint/dsl/` | `numeric`, `string`, `range` refinements (`top_level.rb` removed in v2.0) |
| `lib/minting/mint/aliases.rb` | opt-in `Currency = Mint::Currency` (warn-and-skip if already defined) |
| `lib/minting/money/money.rb` | `Money` core; requires all `money/*` mixins |
| `lib/minting/money/constructors.rb` | `from`, `from_subunits`, `no_currency`, `parse`, `copy_with`, `zero`, deprecated `create`/`mint` |
| `lib/minting/money/arithmetics/` | `methods.rb` (`abs`, `negative?`, `positive?`, `succ`), `operators.rb` (`+`, `-`, `-@`, `*`, `/`, `**`) |
| `lib/minting/money/comparable.rb` | `==`, `eql?`, `<=>`, `same_currency?`, `zero?` — see Equality section |
| `lib/minting/money/coercion.rb` | `coerce` + private `CoercedNumber` |
| `lib/minting/money/format/` | `formatting.rb` (template engine), `to_s.rb` (`to_formatted_s`/`to_s`/`to_fs`, `PRESETS`) |
| `lib/minting/money/allocation/` | `allocation.rb` (`allocate`), `split.rb` (`split`, `allocate_left_over`) |
| `lib/minting/money/clamp.rb`, `conversion.rb` | `clamp`, conversions (`to_d`/`to_f`/`to_i`/`to_r`/`to_json`/`to_hash`/`to_html`) |
| `lib/minting/data/world-currencies.yaml` | 150+ ISO-4217 currencies, loaded lazily by `Registry.world_currencies` |
| `test/test_helper.rb` | SimpleCov + minitest/autorun + requires `minting` |
| `test/minting_test.rb#test_readme_usage` | README contract test — keep in sync with README |
| `bench/check/runner.rb` | core bench runner (Ruby 4.x only) |
| `bin/bench_check` | `bench:check` gate script (threshold 0.80x baseline by default) |

## Deprecated APIs (don't use in new code)

- `Mint::Money.create` → use `Mint::Money.from` (warns).
- `Money#mint(new_amount)` → use `#copy_with(amount:)` (warns, removal in v2).
- `Money.from_fraction` / `#fractional=` → renamed to `from_subunits` /
  `#subunits` in v1.9.0 (breaking).

## When making changes

- Run the specific test file first (`ruby -Ilib:test -r ./test/test_helper.rb
  test/...`), then `bundle exec rake` for the full suite.
- After touching numeric/rounding/constructor behavior, run the relevant
  benchmark too (`rake bench:core`, or `rake bench:check` against the
  baseline). If you improve perf, regenerate the baseline with
  `rake bench:baseline` on the target platform.
- Keep `test_readme_usage` and the README in sync.
- Preserve zero-equality and `eql?` semantics exactly — they're load-bearing
  for Hash-based usage and pinned by many tests.
- Don't remove `Mint::Registry::MUTEX` or the frozen-hash pattern to satisfy
  `ThreadSafety` cops; they're disabled for this reason.

# Roadmap

Prioritized gaps, features, and parity goals for the Minting gem.

**Legend**
- P0 = small scope, high value, ship now
- P1 = correctness & hardening
- P2 = feature parity with the [money gem](https://github.com/RubyMoney/money)
- P3 = polish & community hygiene
- ✅ = done

---

## P0 — Quick wins

| Item | Description | Status |
|------|-------------|--------|

## P1 — Core hardening

| Item | Description | Status |
|------|-------------|--------|
| **P1-1** | Harden registry thread-safety — `@currencies ||=` is unsafe under concurrent load (Puma/Sidekiq). Options: `Mutex`, eager-load in Railtie, `Concurrent::Map` | ✅ |
| **P1-2** | Freeze `currencies` return value — `currencies.delete('USD')` currently mutates the live hash. Return `@currencies.dup.freeze` | ✅ |
| **P1-3** | Symbol-based currency lookup — `Mint.currency_for_symbol(symbol)` | ✅ |
| **P1-4** | String detection helper — `Registry.detect_currency(input)`, used by parser for symbol scan | ✅ |
| **P1-5** | Resolve remaining RuboCop offenses — `Metrics/AbcSize`, `Metrics/ParameterLists`, `ThreadSafety/ClassInstanceVariable` | ✅ |
## P2 — Feature parity with the Money gem

### P2-A Arithmetic & numeric operations

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `divmod` / `div` / `modulo` / `remainder` | `money.divmod(other)`, `money % other`, `money.remainder(other)` | Missing | Low |
| Named constructors | `Money.ca_dollar(100)`, `Money.us_dollar(100)` | ✅ `10.dollars` via refinements only | Done |
| Cross-currency arithmetic | Auto-converts via `exchange_to` when bank has rates | Raises `TypeError` on mismatch | Medium |
| `Money.zero(currency)` / `Money.empty(currency)` | `Money.empty("USD")` → zero money | ✅ `Mint.zero('USD')` returns frozen zero-Money, thread-safe singleton | Done |

### P2-B Exchange rates & bank infrastructure

The Money gem has a full pluggable bank system. Minting has nothing — not planned in the near term.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Bank interface | `Money::Bank::Base` with `#exchange(money, currency)` | Missing | Low |
| In-memory rate store | `Money::RatesStore::Memory` (thread-safe) | Missing | Low |
| Global bank config | `Money.default_bank = bank` | Missing | Low |
| Convert currency | `money.exchange_to("EUR")` | Missing | Low |
| Register rates | `Money.add_rate("USD", "CAD", 1.25)` | Missing | Low |
| Rate import/export | `bank.export_rates(:json)`, `bank.import_rates(:yaml, ...)` | Missing | Low |
| Thread-local bank override | `Money.with_bank(bank) { }` | Missing | Low |
| ECB / OpenExchangeRates stores | `Money::Bank::ECB` (extracted to separate gems) | Missing (future) | Low |

### P2-C Locale / I18n formatting

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| I18n integration | Reads `I18n.t('number.currency.format')` for separators/template | 🔶 Hook in core (`Mint.locale_backend`), wiring in `minting-rails` | High |
| Disambiguated symbols | `format(disambiguate: true)` → `"US$"` vs `"C$"` | Manual only | Medium |
| South Asian numbering | `format(south_asian_number_formatting: true)` → `"1,00,000.00"` | Missing | Low |
| Locale backend selection | `Money.locale_backend = :i18n` / `:currency` | **✅** `Mint.locale_backend` — accepts any callable returning `{ decimal:, thousand:, format: }` | High |

### P2-D Advanced formatting

Minting's `Kernel.format`-based system is more expressive for templates, but lacks convenience flags.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Omit cents | `format(no_cents: true)` → `"$5"` | Manual via `%<amount>d` | Medium |
| Omit cents when whole | `format(no_cents_if_whole: true)` → `"$100"` vs `"$100.34"` | Missing | Medium |
| Symbol control | `format(symbol: false)` / `symbol: "€"` | Via template presence | Medium |
| HTML-wrapped parts | `format(html_wrap: true)` → `<span class="money-...">` | Minting has `to_html` (different approach) | Low |
| Sign before symbol | `format(sign_before_symbol: true)` → `"-£1.00"` | Missing | Low |
| Drop trailing zeros | `format(drop_trailing_zeros: true)` → `"$1.1"` | Missing | Medium |
| Default formatting rules | `Money.default_formatting_rules = { ... }` | Missing | Medium |
| I18n symbol translation | `format(translate: true)` | Missing | Medium |

### P2-E Rounding & precision strategies

Minting always rounds to the currency subunit (good default), but lacks configurability.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Rounding modes | `Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN` | Missing | Medium |
| Thread-local rounding | `Money.with_rounding_mode(mode) { }` | Missing | Low |
| Infinite precision | `Money.default_infinite_precision = true` (keep fractions beyond cents) | Missing | Low |
| Cash rounding | `money.to_nearest_cash_value` (e.g. CHF to nearest 0.05) | Missing | Low |

### P2-F Richer Currency class

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| ISO numeric code | `currency.iso_numeric` (e.g. `"840"`) | Missing | Low |
| Disambiguate symbol | `currency.disambiguate_symbol` (e.g. `"US$"`) | Missing | Medium |
| HTML entity | `currency.html_entity` (e.g. `"&#36;"`) | Missing | Low |
| `symbol_first` | `currency.symbol_first?` | Minting hard-codes symbol-first | Low |
| Smallest denomination | `currency.smallest_denomination` | Missing | Low |
| `Currency.all` sorted list | `Money::Currency.all` | `Mint.currencies.values` | Low |
| Inherit currency | `Money::Currency.inherit("USD", symbol: "CAD$")` | Missing | Low |
| Unregister / reset | `Money::Currency.unregister(:usd)` / `reset!` | Missing | Low |

### P2-G Serialization & conversion

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `to_money(currency)` | Convert self to Money, optionally exchanging | Missing | Low |
| `with_currency("EUR")` | Swap currency without converting | Missing | Low |

## P3 — Polish & community

| Item | Description | Status |
|------|-------------|--------|
| **P3-1** | Add `SECURITY.md` and `CODE_OF_CONDUCT.md` | |
| **P3-2** | Document `Mint.currencies` iteration in README | |
| **P3-3** | Decide and document `Gemfile.lock` policy (gem convention: don't commit) | |
| **P3-4** | Clean up `pkg/` artifacts and add `clobber_pkg` to `Rakefile` | |

---

## Feature parity tracker

Comprehensive comparison between Money gem v6.x and Minting.

✅ = done &emsp; 🔶 = partial &emsp; ❌ = missing &emsp; — = not applicable

| Category | Feature | Money gem | Minting | Priority |
|----------|---------|-----------|---------|----------|
| **Storage** | Internal representation | Integer / BigDecimal | **Rational** ✅ | — |
| | Floating-point safety | BigDecimal | **Rational (no FP at all)** ✅ | — |
| **Creation** | `Money.new(amount, currency)` | ✅ | ✅ `Mint.money(amt, code)` | — |
| | `from_fractional` / `from_cents` | ✅ `Money.from_cents` | ✅ `Money.from_fractional` | — |
| | `Money.empty(currency)` | ✅ | Mint.zero(currency) | ✅  |
| | Named constructors (`us_dollar`, etc.) | ✅ |  ✅  | - |
| | `fractional` / `cents` | ✅ | ✅ `fractional` | — |
| **Arithmetic** | `divmod`, `modulo`, `remainder`, `div` | ✅ | ❌ | Low |
| | Cross-currency arithmetic | 🔶 auto-converts | ❌ raises TypeError | Medium |
| | `+`, `-`, `*`, `/`, `**` | ✅ | ✅ | — |
| | `-@` (negation), `abs` | ✅ | ✅ | — |
| **Comparison** | `<=>`, `==`, `eql?`, `hash` | ✅ | ✅ | — |
| | Zero-equality across currencies | ✅ `Money.new(0, "USD") == 0` | **✅ + eql-shielded** | — |
| | `clamp` | ❌ | ✅ | — |
| **Formatting** | `no_cents`, `no_cents_if_whole` | ✅ | ❌ | Medium |
| | `symbol: true/false` | ✅ | 🔶 manual | Medium |
| | `disambiguate` | ✅ | ❌ | Medium |
| | `html_wrap` | ✅ | 🔶 different `to_html` | Low |
| | `south_asian_number_formatting` | ✅ | ❌ | Low |
| | `drop_trailing_zeros` | ✅ | ❌ | Medium |
| | `to_s` | ✅ | ✅ | — |
| | `Kernel.format`-style templates | ❌ `%u`/`%n` | **✅ `%<symbol>s%<amount>f`** | — |
| | Sign-aware hash format | ❌ | **✅ `{positive:,negative:,zero:}`** | — |
| **Parsing** | `parse(string)` | ✅ (via monetize gem) | ✅ `Mint.parse` | — |
| | Ambiguous separator handling | ✅ | ✅ | — |
| | Accounting negative parsing | ✅ | ✅ | Medium |
| **Exchange** | Bank interface | ✅ <br>`Money::Bank::Base` | ❌ | Low |
| | In-memory rate store | ✅ | ❌ | Low |
| | `exchange_to(currency)` | ✅ | ❌ | Low |
| | `add_rate` / `get_rate` | ✅ | ❌ | Low |
| | Rate import/export (json/yaml) | ✅ | ❌ | Low |
| | ECB / OpenExchangeRates stores | ✅ (extracted) | ❌ | Low |
| **I18n** | I18n integration | ✅ `locale_backend = :i18n` | 🔶 Hook ready, wiring in `minting-rails` | **High** |
| | Per-locale formatting rules | ✅ | ❌ | **High** |
| | Locale backend | ✅ | **✅** `Mint.locale_backend` hook | **High** |
| **Rounding** | Rounding modes | ✅ | ❌ Ruby default | Medium |
| | Infinite precision | ✅ | ❌ | Low |
| | Cash rounding | ✅ | ❌ | Low |
| **Currency** | ISO numeric code | ✅ | ❌ | Low |
| | Disambiguate symbol | ✅ | ❌ | Low |
| | HTML entity | ✅ | ❌ | Low |
| | Symbol first flag | ✅ | ❌ hard-coded | Low |
| | Smallest denomination | ✅ | ❌ | Low |
| | Unregister / reset | ✅ | ❌ | Low |
| | Inherit from currency | ✅ | ❌ | Low |
| | Lookup by ISO code | ✅ `.find` | **✅** `currency_for_code` `currencies` | — |
| | Lookup by symbol | ❌ | **✅** `currency_for_symbol`, `detect_currency` | — |
| **Serialization** | `to_money(currency)` | ✅ | ❌ | Low |
| | `with_currency(code)` | ✅ | ❌ | Low |
| | `to_json` | ✅ | ✅ | — |
| | `to_hash` | ✅ | ✅ | — |
| | `to_html` | ✅ | ✅ | — |
| **Refinements** | `10.dollars` | ❌ | ✅ | — |
| | `10.reais` | ❌ | ✅ | — |
| | `'string'.to_money(code)` | ❌ | ✅ | — |
| **Infrastructure** | RuboCop clean | ❌ | 🔶 3 offenses | Medium |
| | 100% test coverage | ❌ | **✅** | — |
| | Immutable value objects | ❌ | **✅ frozen** | — |
| | Thread-safe registry | ✅ mutex | **✅ Monitor + copy‑on‑write** | Done |
| | Range stepping | ❌ | **✅ `(1..10).step(1)`** | — |

---

## Suggested next steps

1. **minting-rails** — wire `Mint.locale_backend` to `I18n.t('number.currency.format')` in a Railtie

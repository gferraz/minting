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
| **P0-4** | Add CI gate on benchmark regression — fail CI if core ops regress >20% vs stored baseline | Done |

## P1 — Core hardening

| Item | Description | Status |
|------|-------------|--------|
| **P1-1** | Harden registry thread-safety — `@currencies ||=` is unsafe under concurrent load (Puma/Sidekiq). Options: `Mutex`, eager-load in Railtie, `Concurrent::Map` | |
| **P1-2** | Freeze `currencies` return value — `currencies.delete('USD')` currently mutates the live hash. Return `@currencies.dup.freeze` | |
| **P1-3** | Add `inspect` round-trip property test — `Mint.parse(m.inspect)` should round-trip for random amounts | |
| **P1-4** | Resolve remaining 3 RuboCop offenses — `Metrics/AbcSize`, `Metrics/ParameterLists`, `ThreadSafety/ClassInstanceVariable` | |
| **P1-5** | Improve YARD documentation coverage (~55% → 100% public API) — registry methods, allocation, serialization, arithmetic lacking docs | |
| **P1-6** | Mark internal classes `@private` in YARD — `CoercedNumber`, `format_amount` clutter public API stats | |

## P2 — Feature parity with the Money gem

### P2-A Arithmetic & numeric operations

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `divmod` / `div` / `modulo` / `remainder` | `money.divmod(other)`, `money % other`, `money.remainder(other)` | Missing | High |
| `Money.zero(currency)` / `Money.empty(currency)` | `Money.empty("USD")` → zero money | `Mint.money(0, "USD")` works but named constructor is cleaner | Low |
| Named constructors | `Money.ca_dollar(100)`, `Money.us_dollar(100)` | `10.dollars` via refinements only | Low |
| Cross-currency arithmetic | Auto-converts via `exchange_to` when bank has rates | Raises `TypeError` on mismatch | Medium |

### P2-B Exchange rates & bank infrastructure

The Money gem has a full pluggable bank system. Minting has nothing — this is the biggest gap.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Bank interface | `Money::Bank::Base` with `#exchange(money, currency)` | Missing | High |
| In-memory rate store | `Money::RatesStore::Memory` (thread-safe) | Missing | High |
| Global bank config | `Money.default_bank = bank` | Missing | High |
| Convert currency | `money.exchange_to("EUR")` | Missing | High |
| Register rates | `Money.add_rate("USD", "CAD", 1.25)` | Missing | High |
| Rate import/export | `bank.export_rates(:json)`, `bank.import_rates(:yaml, ...)` | Missing | Medium |
| Thread-local bank override | `Money.with_bank(bank) { }` | Missing | Medium |
| ECB / OpenExchangeRates stores | `Money::Bank::ECB` (extracted to separate gems) | Missing (future) | Low |

### P2-C Locale / I18n formatting

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Locale backend selection | `Money.locale_backend = :i18n` / `:currency` | Missing | High |
| I18n integration | Reads `I18n.t('number.currency.format')` for separators/template | Missing | High |
| Disambiguated symbols | `format(disambiguate: true)` → `"US$"` vs `"C$"` | Manual only | Medium |
| South Asian numbering | `format(south_asian_number_formatting: true)` → `"1,00,000.00"` | Missing | Low |

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
| ISO numeric code | `currency.iso_numeric` (e.g. `"840"`) | Missing | Medium |
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
| | `Money.empty(currency)` | ✅ | ❌ | Low |
| | Named constructors (`us_dollar`, etc.) | ✅ | 🔶 via refinements | Low |
| | `fractional` / `cents` | ✅ | ✅ `fractional` | — |
| **Arithmetic** | `+`, `-`, `*`, `/`, `**` | ✅ | ✅ | — |
| | `-@` (negation), `abs` | ✅ | ✅ | — |
| | `divmod`, `modulo`, `remainder`, `div` | ✅ | ❌ | High |
| | Cross-currency arithmetic | 🔶 auto-converts | ❌ raises TypeError | Medium |
| **Comparison** | `<=>`, `==`, `eql?`, `hash` | ✅ | ✅ | — |
| | Zero-equality across currencies | ✅ `Money.new(0, "USD") == 0` | **✅ + eql-shielded** | — |
| | `clamp` | ❌ | ✅ | — |
| **Formatting** | `to_s` | ✅ | ✅ | — |
| | `Kernel.format`-style templates | ❌ `%u`/`%n` | **✅ `%<symbol>s%<amount>f`** | — |
| | Sign-aware hash format | ❌ | **✅ `{positive:,negative:,zero:}`** | — |
| | `no_cents`, `no_cents_if_whole` | ✅ | ❌ | Medium |
| | `symbol: true/false` | ✅ | 🔶 manual | Medium |
| | `disambiguate` | ✅ | ❌ | Medium |
| | `html_wrap` | ✅ | 🔶 different `to_html` | Low |
| | `south_asian_number_formatting` | ✅ | ❌ | Low |
| | `drop_trailing_zeros` | ✅ | ❌ | Medium |
| **Parsing** | `parse(string)` | ✅ (via monetize gem) | ✅ `Mint.parse` | — |
| | Ambiguous separator handling | ✅ | ✅ | — |
| | Accounting negative parsing | ✅ | ❌ documented | Medium |
| **Exchange** | Bank interface | ✅ <br>`Money::Bank::Base` | ❌ | **High** |
| | In-memory rate store | ✅ | ❌ | **High** |
| | `exchange_to(currency)` | ✅ | ❌ | **High** |
| | `add_rate` / `get_rate` | ✅ | ❌ | **High** |
| | Rate import/export (json/yaml) | ✅ | ❌ | Medium |
| | ECB / OpenExchangeRates stores | ✅ (extracted) | ❌ | Low |
| **I18n** | Locale backend | ✅ | ❌ | **High** |
| | I18n integration | ✅ `locale_backend = :i18n` | ❌ | **High** |
| | Per-locale formatting rules | ✅ | ❌ | **High** |
| **Rounding** | Rounding modes | ✅ | ❌ always subunit | Medium |
| | Infinite precision | ✅ | ❌ | Low |
| | Cash rounding | ✅ | ❌ | Low |
| **Currency** | ISO numeric code | ✅ | ❌ | Medium |
| | Disambiguate symbol | ✅ | ❌ | Medium |
| | HTML entity | ✅ | ❌ | Low |
| | Symbol first flag | ✅ | ❌ hard-coded | Low |
| | Smallest denomination | ✅ | ❌ | Low |
| | Unregister / reset | ✅ | ❌ | Low |
| | Inherit from currency | ✅ | ❌ | Low |
| **Serialization** | `to_json` | ✅ | ✅ | — |
| | `to_hash` | ✅ | ✅ | — |
| | `to_html` | ✅ | ✅ | — |
| | `to_money(currency)` | ✅ | ❌ | Low |
| | `with_currency(code)` | ✅ | ❌ | Low |
| **Refinements** | `10.dollars` | ❌ | ✅ | — |
| | `10.reais` | ❌ | ✅ | — |
| | `'string'.to_money(code)` | ❌ | ✅ | — |
| **Infrastructure** | 100% test coverage | ❌ | **✅** | — |
| | Immutable value objects | ❌ | **✅ frozen** | — |
| | Thread-safe registry | ✅ mutex | ❌ | **High** |
| | Range stepping | ❌ | **✅ `(1..10).step(1)`** | — |
| | RuboCop clean | ❌ | 🔶 3 offenses | Medium |

---

## Suggested next steps

1. **P0-1** Fix parse currency detection — small change, big correctness win
2. **P2-B** Start the bank/exchange infrastructure — the single biggest gap to the Money gem
3. **P2-C** I18n formatting — already advertised in README roadmap
4. **P1-1 + P1-2** Thread safety and immutability — production readiness

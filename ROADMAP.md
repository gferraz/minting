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

## P2 — Feature parity with the Money gem

### P2-A Arithmetic & numeric operations

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `divmod` / `div` / `modulo` / `remainder` | `money.divmod(other)`, `money % other`, `money.remainder(other)` | Missing | Low |
| `allocate_max_amounts(amounts)` | `money.allocate_max_amounts([500, 300, 200])` — allocate up to per-part caps, rounds residual | Missing | Medium |
| `calculate_splits(n)` | `money.calculate_splits(3)` → `{ Money => count }` hash | Missing | Medium |
| Configurable leftover distribution | `allocate(ratios, :roundrobin)` / `:roundrobin_reverse` / `:nearest` — selectable rounding strategy during division | Missing | Medium |
| Cross-currency arithmetic | Auto-converts via `exchange_to` when bank has rates | Raises `TypeError` on mismatch | Medium |
| `convert_currency(rate, target)` | `money.convert_currency(exchange_rate, "JPY")` — simple rate-based conversion without bank | Missing | Low |
| **Named constructors** | `Money.ca_dollar(100)`, `Money.us_dollar(100)` | ✅ `10.dollars` | ✅ |
| **`Money.zero` / `Money.empty`** | `Money.empty("USD")` | ✅ `Mint.zero('USD')` | ✅ |

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

The `Mint.locale_backend` hook is provided here; actual I18n wiring belongs in the **`attribute-money`** companion gem.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Disambiguated symbols | :disambiguated option | ✅ `%<dsymbol>s` template placeholder | ✅ |
| South Asian numbering | `format(south_asian_number_formatting: true)` → `"1,00,000.00"` | Missing | Low |
| **I18n integration** | Reads `I18n.t('number.currency.format')` for separators/template | 🔶 Hook in core (`Mint.locale_backend`), wiring in `attribute-money` | ✅ |
| **Locale backend selection** | `Money.locale_backend = :i18n` / `:currency` | **✅** `Mint.locale_backend` — accepts any callable | ✅ |

### P2-D Advanced formatting

All these features are already expressible via `Kernel.format`-style templates in minting, so they are not priority items. Minting deliberately offers a template-based approach rather than convenience boolean flags.

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Omit cents | `$5` | ✅ via `%<amount>d` or `%<integral>`  | ✅ |
| Omit cents when whole | `$100` vs `$100.34` | ✅ via conditionals | ✅ |
| Symbol control | `symbol: false` / `symbol: "€"` | ✅ via template | ✅ |
| HTML-wrapped parts | `<span class="money-...">` | ✅ via `to_html` | ✅ |
| Sign before symbol | `"-£1.00"` | ✅ via template | ✅ |
| Drop trailing zeros | `"$1.1"` | ❌ no dedicated boolean flag (achievable via template, but not a drop-in substitute) | — |
| Default formatting rules | `Money.default_formatting_rules = { ... }` | ✅ via presets and cache | ✅ |
| I18n symbol translation | | ✅ via locales | ✅ |

### P2-E Rounding & precision strategies

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Infinite precision | `Money.default_infinite_precision = true` (keep fractions beyond cents) | Missing | Low |
| Cash rounding | `money.to_nearest_cash_value` (e.g. CHF to nearest 0.05) | Missing | Low |
| **Rounding modes** | `Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN` | ✅ `Mint.with_rounding(:half_even)` — Rational-native, no BigDecimal | ✅ |
| **Thread-local rounding** | `Money.with_rounding_mode(mode) { }` | ✅ `Mint.with_rounding(mode) { }` | ✅ |

### P2-F Richer Currency class

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| ISO numeric code | `currency.iso_numeric` (e.g. `"840"`) | Missing | Low |
| Disambiguate symbol | `currency.disambiguate_symbol` (e.g. `"US$"`) | `currency.disambiguate_symbol` | ✅ |
| HTML entity | `currency.html_entity` (e.g. `"&#36;"`) | Missing | Low |
| `symbol_first` | `currency.symbol_first?` | template placeholder | ✅ |
| Smallest denomination | `currency.smallest_denomination` | Missing | Low |
| `minor_units` / exponent | `currency.minor_units` → `2` | currency.subunit | ✅ |
| `Currency.all` sorted list | `Money::Currency.all` | `Registry.currencies.values` (no public `.all` method) | Low |
| Inherit currency | `Money::Currency.inherit("USD", symbol: "CAD$")` | Missing | Low |
| Unregister / reset | `Money::Currency.unregister(:usd)` / `reset!` | Missing | Low |
| Crypto currencies | `Money.configure { crypto_currencies: true }` — YAML-backed crypto currency support | Missing | Low |
| Custom currencies from YAML | `experimental_custom_currency_path` — load custom currencies from a YAML file | Missing | Low |

### P2-G Serialization & conversion

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `to_money(currency)` | Convert self to Money, optionally exchanging | Missing | Low |
| `with_currency("EUR")` | Swap currency without converting | Missing | Low |
| Subunit converters | `.subunits(format: :stripe)` / `from_subunits(100, 'ISK', format: :stripe)` — pluggable subunit formats for payment provider interop | Missing | Low |
| Custom converters | Subclass `Money::Converters::Converter` to define custom subunit logic | Missing | Low |

### P2-H Infrastructure

| Feature | shopify-money | Minting | Priority |
|---------|-------------|---------|----------|
| RuboCop cops | `Money/MissingCurrency`, `Money/ZeroMoney` — static analysis to enforce currency presence | Missing | Medium |
| RBS type signatures | Full `sig/` directory for type checking | Missing | Low |
| `money_column` AR integration | `money_column :sub_total` — ActiveRecord macro for decimal columns | 🔶 Planned in `attribute-money` | Medium |

## P3 — Polish & community

| Item | Description | Status |
|------|-------------|--------|
| **P3-1** | Add `SECURITY.md` and `CODE_OF_CONDUCT.md` | |
| **P3-2** | Document `Mint.currencies` iteration in README | |
| **P3-3** | Decide and document `Gemfile.lock` policy (gem convention: don't commit) | |
| **P3-4** | Clean up `pkg/` artifacts and add `clobber_pkg` to `Rakefile` | |

---

## Completed

### P1 — Core hardening

| Item | Description |
|------|-------------|
| **P1-1** | Harden registry thread-safety — `@currencies ||=` is unsafe under concurrent load |
| **P1-2** | Freeze `currencies` return value |
| **P1-3** | Symbol-based currency lookup — `Mint.currency_for_symbol(symbol)` |
| **P1-4** | String detection helper — `Registry.detect_currency(input)` |
| **P1-5** | Resolve remaining RuboCop offenses |

### P2-A — Named constructors & zero money

`Money.ca_dollar(100)`, `Money.us_dollar(100)` — ✅ `10.dollars` 

`Money.empty("USD")` → ✅ `Mint.zero('USD')` — frozen zero-Money, thread-safe singleton

### P2-C — I18n infrastructure

I18n integration — ✅ `Mint.locale_backend` hook (wiring in `attribute-money`)

Locale backend selection — ✅ `Mint.locale_backend` — accepts any callable

### P2-D — Advanced formatting (all expressible via Kernel.format templates)

Omit cents, Omit cents when whole, Symbol control, HTML-wrapped parts, Sign before symbol, Drop trailing zeros, Default formatting rules, I18n symbol translation

### P2-E — Rounding

Rounding modes — ✅ `Mint.with_rounding(:half_even)` — Rational-native, no BigDecimal

Thread-local rounding — ✅ `Mint.with_rounding(mode) { }`

### P2-F — Disambiguated symbols

`%<dsymbol>s` format placeholder — ✅ resolves to `currency.disambiguate_symbol` (e.g. `"US$"`, `"C$"`, `"A$"`), falls back to primary symbol when absent

## Feature parity tracker

Comprehensive comparison between Money gem v6.x and Minting.

✅ = done &emsp; 🔶 = partial &emsp; ❌ = missing &emsp; — = not applicable

| Category | Feature | Money gem | Minting | Priority |
|----------|---------|-----------|---------|----------|
| **Storage** | Internal representation | Integer / BigDecimal | **Rational** ✅ | — |
| | Floating-point safety | BigDecimal | **Rational (no FP at all)** ✅ | — |
| **Creation** | `Money.new(amount, currency)` | ✅ | ✅ `Mint.money(amt, code)` | — |
| | `from_fractiona` / `from_cents` | ✅ `Money.from_cents` | ✅ `Money.from_subunits` | — |
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
| | `symbol: true/false` | ✅ | `%<symbol>s` template| ✅ |
| | `disambiguate` | ✅ | ✅ `%<dsymbol>s` template | ✅ |
| | `html_wrap` | ✅ | different `to_html` | ✅ |
| | `south_asian_number_formatting` | ✅ | ❌ | Low |
| | `drop_trailing_zeros` | ✅ |  via template) | - |
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
| **I18n** | I18n integration | ✅ `locale_backend = :i18n` | 🔶 Hook ready, wiring in `attribute-money` | **High** |
| | Per-locale formatting rules | ✅ | 🔶 `Mint.locale_backend` hook ready (wiring in `attribute-money`) | — |
| | Locale backend | ✅ | **✅** `Mint.locale_backend` hook | — |
| **Rounding** | Rounding modes | ✅ | **✅** `Mint.with_rounding(:half_even)` — Rational-native | — |
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
| **Core extensions** | `10.dollars` | ❌ | ✅ | — |
| | `'string'.to_money(code)` | ❌ | ✅ | — |
| **Infrastructure** | RuboCop clean | ❌ | **✅** (0 offenses) | — |
| | 100% test coverage | ❌ | **✅** | — |
| | Immutable value objects | ❌ | **✅ frozen** | — |
| | Thread-safe registry | ✅ mutex | **✅ Monitor + copy‑on‑write** | Done |
| | Range stepping | ❌ | **✅ `(1..10).step(1)`** | — |

---

## Suggested next steps

1. **RuboCop cops** — `Money/MissingCurrency` and `Money/ZeroMoney` for static analysis

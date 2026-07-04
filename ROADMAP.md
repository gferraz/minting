# Roadmap

Prioritized gaps, features, and parity goals for the Minting gem.

**Legend**
- ✅ = done
- 🔶 = partial / moved to companion gem
- ❌ = not planned (revisit if demand rises)

---

## Planned

| Item | Description |
|------|-------------|
| **P3-1** | Add `SECURITY.md` and `CODE_OF_CONDUCT.md` |
| **P3-2** | Document `Currency.all` iteration in README | ✅ |
| **P3-3** | Decide and document `Gemfile.lock` policy (gem convention: don't commit) | ✅ |
| **P3-4** | Clean up `pkg/` artifacts — `rake clobber` covers it via `CLOBBER` | ✅ |

---

## Not planned (unless demand rises)

Everything below is intentionally out of scope for the low-level minting gem.
The existing surface (arithmetic, formatting, parsing, allocation, serialization)
covers the vast majority of real-world usage.

### P2-A Arithmetic & numeric operations

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `divmod` / `div` / `modulo` / `remainder` | `money.divmod(other)`, `money % other`, `money.remainder(other)` | ❌ Not planned | — |
| `allocate_max_amounts(amounts)` | `money.allocate_max_amounts([500, 300, 200])` | ❌ Not planned | — |
| `calculate_splits(n)` | `money.calculate_splits(3)` → `{ Money => count }` hash | ❌ Not planned | — |
| Configurable leftover distribution | `allocate(ratios, :roundrobin)` / `:roundrobin_reverse` / `:nearest` | ❌ Not planned | — |
| Cross-currency arithmetic | Auto-converts via `exchange_to` when bank has rates | ❌ Not planned — raises `TypeError` on mismatch | — |
| `convert_currency(rate, target)` | `money.convert_currency(exchange_rate, "JPY")` | ❌ Not planned | — |

### P2-B Exchange rates & bank infrastructure

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Bank interface | `Money::Bank::Base` with `#exchange(money, currency)` | ❌ Not planned | — |
| In-memory rate store | `Money::RatesStore::Memory` (thread-safe) | ❌ Not planned | — |
| Global bank config | `Money.default_bank = bank` | ❌ Not planned | — |
| Convert currency | `money.exchange_to("EUR")` | ❌ Not planned | — |
| Register rates | `Money.add_rate("USD", "CAD", 1.25)` | ❌ Not planned | — |
| Rate import/export | `bank.export_rates(:json)`, `bank.import_rates(:yaml, ...)` | ❌ Not planned | — |
| Thread-local bank override | `Money.with_bank(bank) { }` | ❌ Not planned | — |
| ECB / OpenExchangeRates stores | `Money::Bank::ECB` (extracted to separate gems) | ❌ Not planned | — |

### P2-C Locale / I18n formatting

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| South Asian numbering | `format(south_asian_number_formatting: true)` → `"1,00,000.00"` | ❌ Not planned | — |

### P2-D Advanced formatting

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Drop trailing zeros | `"$1.1"` | ❌ Not planned (achievable via template, but no drop-in boolean flag) | — |

### P2-E Rounding & precision strategies

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Infinite precision | `Money.default_infinite_precision = true` (keep fractions beyond cents) | ❌ Not planned | — |
| Cash rounding | `money.to_nearest_cash_value` (e.g. CHF to nearest 0.05) | ❌ Not planned | — |

### P2-F Richer Currency class

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| ISO numeric code | `currency.iso_numeric` (e.g. `"840"`) | ❌ Not planned | — |
| HTML entity | `currency.html_entity` (e.g. `"&#36;"`) | ❌ Not planned | — |
| Smallest denomination | `currency.smallest_denomination` | ❌ Not planned | — |
| `Currency.all` | ✅ `Money::Currency.all` returns all registered currencies | ✅ Done | — |
| Inherit currency | `Money::Currency.inherit("USD", symbol: "CAD$")` | ❌ Not planned | — |
| Unregister / reset | `Money::Currency.unregister(:usd)` / `reset!` | ❌ Not planned | — |
| Crypto currencies | YAML-backed crypto currency support | ❌ Not planned | — |
| Custom currencies from YAML | `experimental_custom_currency_path` | ❌ Not planned | — |

### P2-G Serialization & conversion

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `to_money(currency)` | Convert self to Money, optionally exchanging | ❌ Not planned | — |
| `with_currency("EUR")` | Swap currency without converting | ❌ Not planned | — |
| Subunit converters | `.subunits(format: :stripe)` — pluggable formats for payment provider interop | ❌ Not planned | — |
| Custom converters | Subclass `Money::Converters::Converter` | ❌ Not planned | — |
| `to_msgpack` / `from_msgpack` | Binary serialization via `msgpack` gem | ❌ Not planned | — |

### P2-H Infrastructure

| Feature | shopify-money | Minting | Priority |
|---------|-------------|---------|----------|
| RuboCop cops | `Money/MissingCurrency`, `Money/ZeroMoney` | ❌ Not planned | — |
| RBS type signatures | Full `sig/` directory for type checking | ❌ Not planned | — |
| `money_column` AR integration | `money_column :sub_total` — ActiveRecord macro | 🔶 Planned in `attribute-money` | — |

---

## Released

### Core hardening

- Harden registry thread-safety — `@currencies ||=` is unsafe under concurrent load
- Freeze `currencies` return value
- Symbol-based currency lookup — `Mint.currency_for_symbol(symbol)`
- String detection helper — `Registry.detect_currency(input)`

### Named constructors & zero money

- `10.dollars`, `10.reais`, `10.euros`, `n.to_money(currency)` 
- `Money.zero('USD')` — frozen zero-Money singleton, thread-safe

### I18n infrastructure

- `Mint.locale_backend` hook — accepts any callable or Hash for locale-aware formatting defaults
- Locale backend selection — ✅ `Mint.locale_backend = ->(locale) { ... }`

### Advanced formatting

All expressible via `Kernel.format`-style templates:

- Omit cents (`%<amount>d` / `%<integral>d`)
- Symbol control (`%<symbol>s` / omit)
- HTML-wrapped parts (`to_html`)
- Sign before symbol (`%<symbol>s%<amount>+f`)
- Default formatting rules (presets + cache)
- `to_s` / `to_formatted_s` / `to_fs`
- `Kernel.format`-style templates (`%<symbol>s%<amount>f`)
- Sign-aware hash format (`{positive:, negative:, zero:}`)

### Rounding

- `Mint.with_rounding(:half_even)`, `:half_up`, `:half_down`, `:floor`, `:ceil`, `:truncate` — Rational-native, no BigDecimal
- Thread-local rounding — `Mint.with_rounding(mode) { }`

### Currency features

- `currency.disambiguate_symbol` (e.g. `"US$"`, `"C$"`, `"A$"`) + `%<dsymbol>s` template placeholder
- `symbol_first` — handled via template placement
- `currency.subunit` — the exponent (e.g. `2` for USD)
- Lookup by ISO code — `Currency.for_code(code)`, `Registry.currencies`
- Lookup by symbol — `Currency.for_symbol(symbol)`, `Registry.detect_currency(input)`

### Serialization

- `Money.from_hash` — deserializer symmetric with `to_hash`
- `Money#to_hash` — `{ currency:, amount: }`
- `Money#to_html` — `<data class='money'>` element
- `Money.from_json` / `Money#to_json` — 🔶 moved to `attribute-money` gem

### Core extensions

- Numeric refinements — `10.dollars`, `10.reais`, `10.euros`, `n.to_money(currency)`
- `String#to_money(code)` — quick string-to-money (uses `to_r`, not parser)
- `Range#step` with `Money` step — via `RangeStepPatch` on Ruby < 4.0, native on 4.0+

### Infrastructure

Immutable value objects - `Money` frozen on initialize 
Thread-safe registry - `Monitor` + copy-on-write hash replacement 
Range stepping - `(1..10).step(Mint.money(1, 'USD'))` 
80+% test coverage - SimpleCov-verified 
0 RuboCop offenses - Clean on `lib/`

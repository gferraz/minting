# Roadmap

Prioritized gaps, features, and parity goals for the Minting gem.

**Legend**
- ✅ = done
- 🔶 = partial / moved to companion gem
- ❌ = not planned (revisit if demand rises)

## API clarity and usefulness

Prioritized follow-up items from the API review:

- [x] Fix `Money#to_s` losing the minus sign for negative fractional amounts below one unit, e.g. `Money.from(-0.99, 'USD').to_s`.
- [x] Resolve the namespace conflict in `minting/aliases`: it now aliases `Currency` to `Mint::Currency`, regardless of another gem's top-level `Money` constant.
- [x] Keep the Numeric/String helpers as global core extensions for now.
- [x] Keep currency identifiers limited to `String` or `Currency` objects; remove unsupported Symbol claims from public documentation.
- [x] Document that `Money.parse` treats its currency argument as a default: an embedded code or symbol takes precedence.
- [x] Make parsed zero values use the cached zero-money singleton used by constructors.
- [x] Establish `Money.from` as the canonical construction API; retain `dollars`, `euros`, and `reais` as convenience shortcuts. Deprecate redundant `Mint.money` and `Numeric#mint` entry points.
- [x] Expose `country`, `name`, and `disambiguate_symbol` through custom currency registration.
- [x] Make `Currency.world_currencies` explicitly public; it returns the frozen built-in ISO-4217 currency hash.
- [x] Correct README examples and loading instructions, including the undefined `loss` example and crypto examples that use `Currency` without loading `minting/aliases`.
- [x] Document important workflows and edge cases: `parse` versus `parse!`, conversions, division, range clamping, allocation constraints, `to_f` precision loss, and Ruby-version-specific range behavior.
- [x] Align `doc/agents/AGENTS.md` and README claims with implementation, especially `String#to_money`, floating-point wording, and the actual benchmark task names.
- [x] Add `%<sign>s` and `%<magnitude>f` placeholders for explicit sign placement and absolute-value formatting.

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
| `Enumerable` extension for `Money` | `[money1, money2].sum` (no built-in) | ❌ Not planned — collection helpers belong in app layer or companion gem | — |
| `Comparable#between?` with non-zero numeric bounds | `between?(1, 10)` raises `TypeError` (only `0` is allowed) | ❌ Not planned — `<=>` intentionally rejects non-zero scalars | — |

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


### P2-E Rounding & precision strategies

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| Infinite precision | `Money.default_infinite_precision = true` (keep fractions beyond cents) | ❌ Not planned | — |
| Cash rounding | `money.to_nearest_cash_value` (e.g. CHF to nearest 0.05) | Planned | Low |
| Refinement-based rounding | `using Mint::Rounding` to opt-in, zero overhead when unused | Planned | Medium |

### P2-F Richer Currency class

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| ISO numeric code | `currency.iso_numeric` (e.g. `"840"`) | ❌ Not planned | — |
| HTML entity | `currency.html_entity` (e.g. `"&#36;"`) | ❌ Not planned | — |
| Smallest denomination | `currency.smallest_denomination` | ❌ Not planned | — |
| Inherit currency | `Money::Currency.inherit("USD", symbol: "CAD$")` | ❌ Not planned | — |
| Unregister / reset | `Money::Currency.unregister(:usd)` / `reset!` | ❌ Not planned | — |
| Custom currencies from YAML | `experimental_custom_currency_path` | ❌ Not planned | — |

### P2-G Serialization & conversion

| Feature | Money gem | Minting | Priority |
|---------|-----------|---------|----------|
| `to_money(currency)` | convert objects to Money, optionally exchanging | 🔶 conversion is done, but no exchange | — |
| `with_currency("EUR")` | Swap currency without converting | ❌ Not planned | — |
| Subunit converters | `.subunits(format: :stripe)` — pluggable formats for payment provider interop | ❌ Not planned | — |
| Custom converters | Subclass `Money::Converters::Converter` | ❌ Not planned | — |
| `to_msgpack` / `from_msgpack` | Binary serialization via `msgpack` gem | ❌ Not planned | — |

### P2-H Infrastructure

| Feature | shopify-money | Minting | Priority |
|---------|-------------|---------|----------|
| RuboCop cops | `Money/MissingCurrency`, `Money/ZeroMoney` | ❌ Not planned | — |
| RBS type signatures | Full `sig/` directory for type checking | ❌ Not planned | — |

### P3 Polish

| Item | Description |
|------|-------------|
| **P3-1** | Add `SECURITY.md` and `CODE_OF_CONDUCT.md` | ❌ Not planned |

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
- Locale backend selection — `Mint.locale_backend = ->(locale) { ... }`

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

- `Mint.with_rounding(:even)`, `:up`, `:down` — `Rational#round` native, no BigDecimal
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
- `money_column` AR integration — `money_column :sub_total` ActiveRecord macro in `attribute-money`

### Core extensions

- Numeric refinements — `10.dollars`, `10.reais`, `10.euros`, `n.to_money(currency)`
- `String#to_money(code)` — quick string-to-money (uses `to_r`, not parser)
- `Range#step` with `Money` step — via `RangeStepPatch` on Ruby < 4.0, native on 4.0+

### P3 Polish

- `Currency.registered_currencies` — public access to all registered currencies
- `Gemfile.lock` policy — gitignore, don't commit (gem convention)
- `pkg/` artifacts — `rake clobber` covers cleanup via `CLOBBER.include`
- Crypto currency support — `Registry.crypto_currencies` + `Registry.register_crypto` (opt-in YAML-backed definitions for ~25 popular coins)

### Infrastructure

- Immutable value objects - `Money` frozen on initialize 
- Thread-safe registry - `Monitor` + copy-on-write hash replacement 
- Range stepping - `(1..10).step(Money.from(1, 'USD'))`
- 80+% test coverage - SimpleCov-verified 
- 0 RuboCop offenses - Clean on `lib/`

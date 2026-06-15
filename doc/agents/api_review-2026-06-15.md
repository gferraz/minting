# Minting gem API review

**Data:** 2026-06-15
**Author:** Wave AI (via Wave Terminal assistant)

## 1. Top-level API surface (Mint / Money / Currency)

### What’s good

- `Mint.money(10, 'USD')` is clear and discoverable.
- Refinements (`10.dollars`, `4.to_money('USD')`) are modern and opt-in.
- Optional `minting/dsl` with `Money` / `Currency` constants is a good compromise for ergonomics vs. gem conflicts.

### Suggestions

1. **Tighten constructor story (too many verbs)**  
   Right now you have:
   - `Mint.money(amount, code)`
   - `Mint.zero(currency)`
   - `Mint::Money.create(amount, currency)`
   - `Mint::Money.from_fractional(fractional, currency)`
   - `Money.create` / `Money.from_fractional` / `price.mint(new_amount)` (instance)

   Consider a simpler, more opinionated set:

   - **Class side:**
     - `Money.from(amount, currency)` (instead of `create`)
     - `Money.from_fractional(fractional, currency)`
   - **Module side:**
     - `Mint.money(amount, currency)` (delegates to `Money.from`)
     - `Mint.from_fractional(fractional, currency)` (delegates to `Money.from_fractional`)
     - `Mint.zero(currency)`

   And **remove / de-emphasize** `Money.create` from public docs (keep as private alias if needed).

2. **Rename `mint(new_amount)` → clearer “copy with” semantics**

   `price.mint(15.00)` is cute but not self-describing. Consider:

   - `price.with_amount(15.00)`
   - or `price.change(amount: 15.00)`
   - or `price.rebuild(15.00)` (less good, but at least indicates a copy)

   And surface this in README (“Immutability helpers”).

3. **Top-level constants: make the opt-in path prominent, but one-liner**

   You already have:

   ```ruby
   require "minting"
   require "minting/dsl"  # opt-in top‑level Money / Currency
   ```

   For Rails developers, you might recommend in README:

   ```ruby
   # config/initializers/minting.rb
   require "minting/dsl"
   ```

   And add a short “Rails setup” snippet, since that’s what competing gems usually highlight first.

---

## 2. Money semantics & naming

### Zero equality semantics

You do something non-standard and powerful:

```ruby
Mint.money(0, 'USD') == Mint.money(0, 'EUR') # => true
Mint.money(0, 'USD') == 0                    # => true
```

This is very nice for totals, but surprising vs. `money` gem.

**Changes:**

1. **Make this a named feature, with an escape hatch**

   - Give it a name in docs: e.g. “currency-agnostic zero”.
   - Provide an **explicit predicate or helper**:

     ```ruby
     price.zero?     # usual predicate
     price.strictly_zero_in?('USD') # same_currency? + zero?
     ```

   - Consider a **config flag** or alternate comparator:

     ```ruby
     Mint.strict_zero_comparison = true
     # or
     price.eql_in_currency?(other_price)
     ```

2. **Docs: add a clear “Gotchas” section**  
   Call out at the bottom of README “Behavior that differs from `money` gem”, starting with zero. This directly addresses “gap to competitors” and reduces surprises.

### `same_currency?`

Current doc:

```ruby
# @param other [Currency] the target currency to compare
def same_currency?(other) = other.currency == currency
```

This is odd: the param type is a `Currency` in the docs, but you call `other.currency` which implies it’s actually `Money`.

**Change:**

- Decide on the intent; then:
  - If it compares two `Money` objects, define:

    ```ruby
    # @param other [Money]
    def same_currency?(other) = other.currency == currency
    ```

  - Or if you want both forms, accept either and update docs:

    ```ruby
    def same_currency?(other)
      other_currency =
        case other
        when Mint::Money   then other.currency
        when Mint::Currency then other
        else
          Currency.resolve!(other)
        end

      other_currency == currency
    end
    ```

- Consider renaming to `same_currency_as?(other)` to better match Ruby predicate idioms and feel less “type-ish”.

---

## 3. Parsing API

`Mint.parse` is already strong. To beat competitors, lean into this.

### Suggestions

1. **Return type & error modes**

   - Document explicitly that `Mint.parse` returns `Mint::Money`.
   - Add **two modes**:
     - `Mint.parse!(...)` – raises on failure.
     - `Mint.parse(...)` – returns `nil` on failure or perhaps `Result` object in future, but nil is sufficient initially.

2. **Expose configuration hooks**

   Even if not fully implemented yet, define the shape:

   ```ruby
   Mint.parser.default_currency = 'USD'
   Mint.parser.symbol_priority = %w[USD CAD AUD]
   ```

   That gives you a path to match/beat `monetize` / `money` ecosystem flexibility.

3. **Quality-of-life alias**

   - `Mint.money_from(str, currency_code = nil)`
   - Or a class method: `Mint::Money.parse(str, currency: nil)`

   That keeps “all money stuff under Money” for folks who avoid module functions.

---

## 4. Formatting API

Current:

- `to_s(format: '%<symbol>s%<amount>f')`
- Hash format for per-sign: `{ negative: '(%<symbol>s%<amount>f)' }`

This is powerful but low-level. Competing gems typically offer higher-level presets and localization.

### Suggestions

1. **Named formats / shortcuts**

   Something like:

   ```ruby
   price.format          # same as to_s
   price.format(:iso)    # "USD 9.99"
   price.format(:symbol) # "$9.99"
   price.format(:code)   # "9.99 USD"
   ```

   Internally, use a format registry:

   ```ruby
   Mint.formats.register(:iso, '%<currency>s %<amount>f')
   ```

2. **Accounting format shortcut**

   You already support per-sign hash formats; expose a named helper:

   ```ruby
   price.to_accounting   # ($1,234.56) for negatives, 0.00 for zero
   ```

3. **JSON / Rails integration**

   You have:

   ```ruby
   price.to_json  # => {"currency":"USD","amount":"9.99"}
   price.to_hash  # => { currency: "USD", amount: "9.99" }
   ```

   For better Rails DX & parity:

   - Add `as_json` delegating to `to_hash`.
   - Mention in README: “Works with Rails serialization (`as_json` implemented).”

---

## 5. Currency API

Current:

- `Mint.currency_for_code('USD')`
- `Mint.currency_for_symbol('$')`
- `Mint.register_currency(...)`
- `Mint.world_currencies` (+ internal `Registry`)

### Suggestions

1. **Consistent names & variants**

   Consider:

   - `Mint.currency('USD')` → primary lookup (by code; maybe symbol in future).
   - Keep `currency_for_code` / `currency_for_symbol` as explicit variants, but guide people to the simple `currency`.

2. **Clarify custom currency lifecycle**

   Competitors often have quirks here; you can win on clarity:

   - Are custom currencies persisted per process?
   - Are they thread-safe?
   - Are they ordered by `priority` in deterministic way?

   Add a small “Custom currencies” section with examples and guarantees.

3. **Expose the registry read-only**

   Instead of `world_currencies` returning “the frozen world-currencies hash” (but you also have `Registry.currencies`), maybe have:

   ```ruby
   Mint.currencies # => { "USD" => <Currency>, ... } (frozen hash)
   ```

   And keep `Registry` private in docs.

---

## 6. Error types & clarity

### UnknownCurrency

```ruby
# Unknown currency excpetion
class UnknownCurrency < StandardError; end
```

- Typo in comment (“excpetion”).
- Recommend renaming to `UnknownCurrencyError` for conventional Ruby style.
- Ensure it’s actually raised from `Currency.resolve!` (and document that).

### Validation errors

You currently raise `ArgumentError` for several things (`amount must be Numeric`, `fractional must be an Integer`).

Consider:

- Keeping `ArgumentError` but **documenting all the failure cases** in YARD and README.
- Or, for one level up in clarity, introduce:

  ```ruby
  class InvalidMoneyArgument < ArgumentError; end
  ```

  and use that everywhere. This is a small DX win in large apps.

---

## 7. Documentation structure (DX & competitiveness)

Your README is already strong. To push it over the top vs. `money` gem and friends:

1. **Add a “Comparison” section**

   Not necessarily with names, but structurally:

   - “What Minting does differently”
     - Always-exact `Rational` amounts.
     - Currency-agnostic zero.
     - Faster formatting (link benchmarks).
     - Separate `minting-rails` companion for clean Rails integration.

2. **Add “Common tasks” cheatsheet**

   Short, scannable table:

   | Task                          | Code                              |
   |------------------------------|-----------------------------------|
   | New amount                   | `Mint.money(10, 'USD')`          |
   | From cents                   | `Mint::Money.from_fractional(999, 'USD')` |
   | Change amount immutably      | `price.with_amount(15)` (or `mint`) |
   | Parse user input             | `Mint.parse('$19.99')`           |
   | Serialize to JSON            | `price.to_hash` / `price.as_json` |
   | Clamp to range               | `price.clamp(0, 100)`            |
   | Split / allocate             | `ten.split(3)` / `ten.allocate([...])` |

   This directly optimizes developer experience.

3. **Prominent “Rails” heading**

   Right now you just mention `minting-rails`. Make it a full section:

   - How to add gem.
   - Example migration / attribute definition (even if in the other repo, mirror one snippet here).

---

## 8. Minor polish

- In `README` “Json serialization” → “JSON serialization”.
- Make sure `Mint::Money`’s `inspect` and `to_s` are clearly differentiated in docs:
  - `inspect` → developer/debugging (`[USD 10.00]`).
  - `to_s` → user-facing, configurable formatting.

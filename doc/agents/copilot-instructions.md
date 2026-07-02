Repository overview

- Language: Ruby gem (minting)
- Location of main code: lib/minting and its subfolders (mint/, money/)
- Public API surface: Mint (factory/helpers), Mint::Money, Mint::Currency
- Data: built-in currencies in lib/minting/data/currencies.yaml
- Tests: Minitest (unit) + performance benchmarks under bench/

Build, test and lint commands

- Install dependencies:
  - bundle install

- Run full test suite (default task):
  - bundle exec rake
  - or simply: rake

- Run a single test file (recommended when iterating):
  - ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb

- Run a single test method by name (Minitest -n regexp):
  - ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb -n /test_creation/


- Linting:
  - bundle exec rake cop
  - or: bundle exec rubocop

- Build gem package:
  - gem build minting.gemspec

- Documentation:
  - bundle exec rake yard

- README verification:
  - README examples are exercised by `test/minting_test.rb#test_readme_usage`.
  - Prefer the README as the authoritative usage guide for feature behavior and examples.

High-level architecture (big picture)

- Top-level: lib/minting.rb requires the Mint module and Money implementation.
- Mint module: currency registry and factory helpers live in lib/minting/mint/*. Registry loads lib/minting/data/currencies.yaml on first access.
- Currency: lightweight value object (code, subunit, symbol, priority, minimum_amount).
- Money: immutable value object stored as Rational and rounded to currency.subunit. Core concerns split across lib/minting/money/* (arithmetics, formatting, conversion, coercion, allocation, parsing, comparable).
- Refinements: Numeric/String/Refinements in lib/minting/mint/refinements.rb expose helpers like 10.dollars, 4.to_money('USD'), and require `using Mint` in scope.
- Performance tests: separate bench tasks under Rake; bench/ holds benchmark suites.

Key conventions and repo-specific rules

- Exactness: amounts are stored as Rational and rounded to the currency subunit. Prefer rationals or decimal strings (e.g., '19.99'.to_r or 1999/100r) when precision is needed.
- Zero equality: zeros are equal across currencies (Mint.money(0,'USD') == Mint.money(0,'EUR') == 0). Non-zero comparisons require identical currency and amount.
- Currency registration: use Mint.register_currency for idempotent registration; Mint.register_currency! raises on duplicates. Codes must match /^[A-Z_]+$/.
- Symbol parsing: parser resolves symbols by longest match then currency priority (see Mint.currency_symbols sorting).
- Tests: test_helper.rb configures coverage (SimpleCov) and loads minitest; when running tests outside rake, require test_helper (-r ./test/test_helper.rb).
- Formatting: Money.to_s uses Kernel.format patterns; take care with %<amount>f vs %<amount>d depending on desired rounding/formatting.

Files and places to check first during edits

- lib/minting/money - core behavior and arithmetic
- lib/minting/mint - currency registry, refinements, and factory API
- lib/minting/data/currencies.yaml - canonical currency definitions
- test/ - unit tests; bench/ - benchmark suites

Notes for Copilot sessions

- Prefer making atomic changes and run the unit test(s) covering the changed area. Use the single-file test invocation above when iterating rapidly.
- When changing numeric/rounding behavior, run both unit tests and relevant performance benchmarks.
- Respect zero-equality semantics and currency code validation when modifying equality/hash logic.

If you want, update this file with project-specific conventions to capture workflow choices (e.g., backport policy, DI patterns).
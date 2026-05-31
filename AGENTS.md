# AGENTS.md

Purpose: concise instructions for AI coding agents working on the minting Ruby gem.

Key links:
- README.md
- .github/copilot-instructions.md

Quick commands:
- Install: bundle install
- Full test suite: rake
- Single test file: ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb
- Single test method: ruby -Ilib:test -r ./test/test_helper.rb test/money/money_test.rb -n /test_creation/
- Lint: bundle exec rake cop

Project highlights & conventions:
- Language: Ruby gem (minting)
- Main code: lib/minting (mint/, money/)
- Currency data: lib/minting/data/currencies.yaml
- Amounts stored as Rational; prefer rationals or decimal strings for precision
- Zero-equality: zeros equal across currencies; non-zero comparisons require same currency
- Currency codes must match /^[A-Z_]+$/
- Tests: Minitest; performance benches under test/performance (use BENCH=true)

Edit guidance: keep this file minimal and link to existing docs; add repo-specific agent tips here.

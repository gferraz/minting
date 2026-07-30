# Security and Memory Leak Review Report

**Date**: 2026-07-29  
**Project**: minting Ruby gem  
**Version**: 2.0 release
**Author**: devin, model SWE 1.6

## Executive Summary

This review identified **2 security vulnerabilities** (1 medium, 1 low) and **3 memory leak concerns** (1 high, 1 medium, 1 low-medium) in the minting gem. The codebase demonstrates good practices with thread-safe registry operations, proper object freezing, and input validation. The primary concerns are around unbounded caching in long-running processes and unsafe YAML loading.

## Security Vulnerabilities

### 1. Unsafe YAML Loading (Medium Risk)

**Location**: 
- `lib/minting/mint/registry/registry.rb:18-21`
- `lib/minting/mint/registry/crypto.rb:20-21`

**Issue**: The code uses `YAML.load_file` which can execute arbitrary Ruby code if the YAML files are malicious:

```ruby
@world_currencies = YAML.load_file(path).to_h do |entry|
  [entry['code'], Currency.new(**entry.transform_keys(&:to_sym))]
end
```

**Risk**: While the bundled YAML files are trusted, if an attacker can replace these files (e.g., through supply chain attack or file system compromise), they could execute arbitrary code.

**Recommendation**: Use `YAML.safe_load` with permitted classes:
```ruby
YAML.safe_load(File.read(path), permitted_classes: [Symbol])
```

### 2. Potential ReDoS in Regex (Low Risk)

**Location**: 
- `lib/minting/money/format/to_s.rb:11`
- `lib/minting/money/format/formatter.rb:43`

**Issue**: The thousand separator regex `THOUSAND_RE = /(\d)(?=(\d{3})+\z)/` could potentially cause ReDoS with very long strings.

**Risk**: This is mitigated by:
- Money amounts are typically bounded
- The regex is anchored with `\z`

**Recommendation**: Consider adding input validation or length limits for formatting operations.

## Memory Leaks

### 1. Unbounded Formatter Cache (High Risk)

**Location**: `lib/minting/money/format/formatter.rb:15`

**Issue**: The formatter cache grows unbounded with each unique `[format, decimal, thousand]` combination:

```ruby
def self.cache = @cache ||= {}
```

**Risk**: In long-running processes (e.g., web servers) with user-supplied format strings, this could lead to significant memory growth over time.

**Recommendation**: Implement cache size limits or LRU eviction:
```ruby
def self.cache = @cache ||= LRUHash.new(max_size: 1000)
```

### 2. Thread-Local Storage Not Cleaned (Medium Risk)

**Location**: `lib/minting/currency/rounding.rb:40-44`

**Issue**: Thread-local state persists between requests in thread pool environments:

```ruby
prev = Thread.current[ROUNDING_THREAD_KEY]
Thread.current[ROUNDING_THREAD_KEY] = mode
yield
ensure
  Thread.current[ROUNDING_THREAD_KEY] = prev
```

**Risk**: While the `ensure` block restores the previous value, if threads are pooled and reused, the thread-local state persists between requests. This could cause unexpected behavior in web server environments.

**Recommendation**: Document this behavior or add cleanup hooks for thread pool environments.

### 3. Per-Subunit Template Cache Growth (Low-Medium Risk)

**Location**: `lib/minting/money/format/formatter.rb:104-106`

**Issue**: This hash grows with each unique subunit value:

```ruby
@templates_by_subunit = Hash.new do |h, subunit|
  h[subunit] = @templates.transform_values { |f| f.gsub(SUBUNIT_PLACEHOLDER, subunit.to_s) }
end
```

**Risk**: While bounded in practice (typical subunits are 0-3), it could grow if many custom currencies with different subunits are registered.

**Recommendation**: This is likely acceptable given the bounded nature of subunits, but consider adding a size limit.

## Positive Security Findings

1. **Thread-safe registry**: The registry uses proper `Monitor` synchronization (`lib/minting/mint/registry/registration.rb:22-29`)
2. **Frozen objects**: Money and Currency objects are properly frozen after initialization (`lib/minting/money/constructors.rb:97`)
3. **Input validation**: Good validation in parsing and formatting methods
4. **No known vulnerabilities**: `bundle exec rake bundle:audit` found no vulnerabilities in dependencies

## Other Concerns

1. **String mutation**: Use of `gsub!` and `sub!` (`lib/minting/money/format/formatter.rb:72-76`) could be problematic if strings are shared, though this appears safe in the current implementation.

2. **Zero singleton cache**: The `@zeros` cache (`lib/minting/mint/registry/zeros.rb`) grows with each unique currency but is properly synchronized and bounded by registered currencies.

## Recommendations Priority

### High Priority
1. Replace `YAML.load_file` with `YAML.safe_load` in registry files
2. Implement formatter cache size limits or LRU eviction

### Medium Priority
3. Document thread-local storage behavior for thread pool environments
4. Consider adding cleanup hooks for thread pool environments

### Low Priority
5. Add input length validation for formatting operations
6. Consider adding size limits to per-subunit template cache

## Conclusion

The minting gem demonstrates good security practices with proper thread safety, immutability, and input validation. The main concerns are around unbounded caching in long-running processes and the unsafe YAML loading. Addressing the high-priority recommendations would significantly improve the security posture and memory efficiency of the library in production environments.

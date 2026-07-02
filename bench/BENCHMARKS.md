# Performance Benchmarks

This directory contains comprehensive performance benchmarks for the Minting gem.

## Quick Start

```bash
rake bench:all                # Run core/memory/regression benchmarks
rake bench:against:money      # Compare Minting vs Money gem (v7.0.2)
rake bench:against:shopify    # Compare Minting vs Shopify Money (v4.1.1)
rake bench:core               # Core operation performance
rake bench:memory             # Memory allocation analysis
rake bench:regression         # Performance regression detection
rake bench:check              # Check core ops against baseline (CI gate)
rake bench:baseline           # Update baseline for bench:check
```

## Minting vs Money (v7.0.2) vs Shopify Money (v4.1.1)

Benchmarks run on Ruby 4.0.5 (arm64-darwin23), 2026-07-01. All figures in **operations/second** (higher is better). Ratios > 1.0x favor Minting.

### Object Creation

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|---|
| `Mint.money` | 885k | — | — | — | — |
| `Mint.from_subunits` | 1,044k | — | 1,144k | — | **same-ish** |
| `some.dollars` syntax | 887k | — | — | — | — |
| `Money.new` | — | 1,268k | — | — | — |
| `Money.from_amount` | — | 641k | — | — | — |
| `Shopify Money.new` | — | — | 715k | — | — |

Minting's `from_subunits` is competitive with `Money.new` (direct cents). `Mint.money` and the DSL are 1.4x slower than `Money.new` due to Currency resolution overhead, but still faster than `Money.from_amount`.

### Arithmetic Operations

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| Addition | 872k | 670k | 859k | **1.30x** | **same-ish** |
| Subtraction | 907k | 670k | 853k | **1.35x** | **1.04x** |
| Multiplication (scalar) | 1,155k | 826k | 734k | **1.40x** | **1.53x** |
| Division (scalar) | 1,026k | 551k | — | **1.86x** | — |
| Division (ratio) | 4,061k | 724k | — | **5.61x** | — |
| Negation | 1,429k | 965k | 1,638k | **1.48x** | 0.87x |
| Abs | 736k | 487k | 788k | **1.51x** | 0.91x |

> Shopify Money does not support `Money / Money` (raises `[Money] Dividing money objects can lose pennies`) or `Money / Float` (raises for same reason). Scalar division tests use only Integer dividers.

### Comparison Operations

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| `==` (same value) | 2,117k | 651k | 3,593k | **3.25x** | 0.59x |
| `==` (different value) | 2,317k | 645k | 3,717k | **3.59x** | 0.62x |
| `==` (different currency) | 1,813k | 296k | 4,549k | **6.12x** | 0.40x |
| `>` | 1,894k | 705k | 1,770k | **2.68x** | **1.07x** |
| `<=>` | 2,031k | 732k | 1,832k | **2.77x** | **1.11x** |
| `.hash` | 4,368k | 2,512k | 10,369k | **1.74x** | 0.42x |

Minting is significantly faster than the Money gem for all comparison operations. Shopify Money is faster for `==` and `.hash` due to simpler internal state (integer subunits vs Rational).

### Formatting / String Operations

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| `to_s` (amount 123.45) | 898k | 226k | 2,413k | **3.98x** | 0.37x |
| `inspect` (amount 123.45) | 2,441k | 1,568k | 1,662k | **1.56x** | **1.47x** |
| `to_json` (amount 123.45) | 2,076k | 209k | 848k | **9.94x** | **2.45x** |

Shopify Money's `to_s` is fast (3x Minting) because it formats from cached integer subunits. Minting's `inspect` is faster than both competitors. Minting's `to_json` dominates both.

### Numeric Conversion

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| `to_i` | 11,992k | 933k | 10,917k | **12.85x** | **1.10x** |
| `to_f` | 7,719k | 851k | 5,322k | **9.07x** | **1.45x** |
| `to_d` | 2,652k | 951k | 20,354k | **2.79x** | 0.13x |
| `to_r` | 13,707k | — | — | — | — |

Minting's `to_i` and `to_f` are extremely fast (Rational stores numerator/denominator — `to_i` is integer division, `to_f` is float division). `to_d` is slower because it converts via `Rational#to_f` → `BigDecimal`. Shopify Money stores amounts as `BigDecimal` internally, making `to_d` near-instant.

### Currency Lookup

| Operation | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| Currency resolve | 6,871k | 2,546k | 4,853k | **2.70x** | **1.43x** |

### Split & Allocation

| Scenario | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| Split 6 ways (small) | 362k | 164k | 181k | **2.21x** | **2.00x** |
| Split 7 ways (small) | 298k | 136k | 182k | **2.20x** | **1.64x** |
| Split 1830 ways (small) | 2,295 | 644 | 12,153 | **3.56x** | 0.19x |
| Split 6 ways (large) | 316k | 159k | 178k | **1.99x** | **1.78x** |
| Split 7 ways (large) | 312k | 140k | 180k | **2.22x** | **1.73x** |
| Split 1830 ways (large) | 1,933 | 644 | 12,095 | **3.00x** | 0.16x |
| Allocate [1,2,3] (small) | 358k | 274k | 58k | **1.31x** | **6.15x** |
| Allocate [0.25,1.25,2.25,3.25] (small) | 211k | 89k | 43k | **2.37x** | **4.95x** |
| Allocate [1..60] (small) | 22k | 19k | 3.8k | **1.16x** | **5.76x** |
| Allocate [1,2,3] (large) | 286k | 275k | 58k | **1.04x** | **4.96x** |
| Allocate [0.25,1.25,2.25,3.25] (large) | 208k | 89k | 42k | **2.32x** | **4.96x** |
| Allocate [1..60] (large) | 20k | 18k | 3.5k | **1.09x** | **5.77x** |

Minting's `split` is ~2x faster than the Money gem for small N and ~3x faster for large N. Shopify Money's `split` is slower for small N but significantly faster for large N (their lazy enumerator + `.to_a` is still more efficient at scale). Minting's `allocate` dominates both competitors — 1.2–2.4x faster than Money gem and 5–6x faster than Shopify Money, whose allocator internally converts to Rational via string parsing.

### High-Volume Transaction Simulation

| Metric | Minting | Money gem | Shopify Money | vs Money | vs Shopify |
|---|---|---|---|---|---|
| Time (50k transactions) | 279ms | 390ms | 310ms | **1.40x faster** | **1.07x faster** |
| Throughput (ops/sec) | 179,251 | 128,341 | 161,388 | **1.40x** | **1.11x** |

### Memory Usage (10,000 object creations)

| Metric | Minting | Money gem | Shopify Money |
|---|---|---|---|
| T_STRUCT allocated | 164 | 0 | 0 |
| T_STRING allocated | 866 | 0 | 0 |
| T_HASH allocated | 20 | 1 | 1 |
| T_IMEMO allocated | 186 | 33 | 37 |
| TOTAL (post-GC) | 5,321 | ~0 | 2,455 |

Minting allocates more Ruby objects per Money instance due to the `Rational` amount and `Currency` value-object. Both the Money gem and Shopify Money store cached integer subunits in C extensions, minimizing allocation.

## Notes

- **Money gem 7.0.2** has significantly improved performance over earlier versions in several areas.
- **Shopify Money 4.1.1** is a standalone fork of the Money gem (not a wrapper). It stores amounts as `BigDecimal` internally, which makes `to_d` extremely fast but allocation/split operations slower due to string → Rational conversion.
- Division by another `Money` or by `Float` raises in Shopify Money to prevent precision loss — use `#split` instead. Minting supports both.
- `to_d` is slower in Minting because it converts via `Rational#to_f` → `BigDecimal`. Use `to_r` for zero-allocation conversion.
- Competitive benchmarks are fully isolated via per-directory `Gemfile`s. Run `rake bench:against:money` or `rake bench:against:shopify`.
- `BUNDLE_WITHOUT` is no longer used for isolation — each competitor has its own `BUNDLE_GEMFILE`.

## Benchmark Categories

### 1. Competitive Benchmark
**Purpose**: Compares Minting performance against Money gem (v7.0.2) and Shopify Money (v4.1.1)
- Object creation comparison
- Arithmetic operation comparison
- Memory usage comparison
- High-volume transaction simulation

### 2. Core Operations Benchmark
**Purpose**: Measures basic operation performance and algorithms
- Money creation with different data types
- Arithmetic operations (+, -, *, /, abs)
- Comparison operations (==, <=>, >, hash)
- Currency lookup and registration
- Algorithms
  - Split performance with different amounts and split sizes
  - Allocation performance with various proportion patterns
  - Precision edge cases with different currencies
  - Remainder distribution scenarios
  - Pathological edge cases

**Key Metrics**:
- Operations per second for each operation type
- Performance vs. data size scaling
- Accuracy of allocation results
- Edge case handling performance

### 3. Memory Benchmark
**Purpose**: Analyzes memory allocation and garbage collection
- Object allocation patterns
- Memory retention testing (leak detection)
- Garbage collection pressure analysis
- Large-scale operation memory usage

**Key Metrics**:
- Object allocation counts by type
- GC statistics (major/minor GC counts)
- Memory stability over time

### 4. Regression Benchmark
**Purpose**: Detects performance regressions using Minitest::Benchmark
- Ensures operations maintain expected Big-O complexity
- Constant time operation verification
- Linear scaling validation
- Memory stability testing

**Key Metrics**:
- Performance complexity validation (constant/linear)
- Regression detection over time

## Environment Variables

- `RUBY_PROF=true` - Enable ruby-prof profiling (if available)
- `BUNDLE_GEMFILE` - Set to a competitor's Gemfile for isolated benchmark runs

## Performance Targets

### Core Operations
- **Object Creation**: > 500K ops/sec
- **Arithmetic**: > 1M ops/sec
- **Comparisons**: > 2M ops/sec
- **String Operations**: > 100K ops/sec

### Memory Usage
- **Money Creation**: < 2 objects per money instance
- **Arithmetic**: Minimal temporary object creation
- **No Memory Leaks**: Stable object counts over time

### Algorithm Performance
- **Split Algorithm**: Linear scaling O(n)
- **Allocation Algorithm**: Linear scaling O(n)
- **Remainder Distribution**: Accurate to currency subunit

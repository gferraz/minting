# Performance Benchmarks

This directory contains comprehensive performance benchmarks for the Minting gem.

## Quick Start

```bash
rake bench:all            # Run all benchmarks
rake bench:competitive    # Compare Minting vs Money gem
rake bench:core           # Core operation performance
rake bench:memory         # Memory allocation analysis
rake bench:regression     # Performance regression detection
rake bench:check          # Check core ops against baseline (CI gate)
rake bench:baseline       # Update baseline for bench:check
```

## Minting vs Money vs Shopify Money

Benchmarks run on Ruby 4.0.5 (arm64-darwin23). All figures in **operations/second** (higher is better).

### Object Creation

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `Mint.money` / `Money.new(cents)` | 870,000 | 636,000 | — | **1.4x** | — |
| `Mint.money` / `Money.from_amount` | 870,000 | 379,000 | 376,000 | **2.3x** | **2.3x** |
| `Mint.from_subunits` / `Money.new(cents)` | 1,000,000 | 636,000 | 376,000 | **1.6x** | **2.7x** |
| `some.dollars` syntax | 781,000 | — | — | — | — |

### Arithmetic Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| Addition | 822,000 | 312,000 | — | **2.6x** | — |
| Subtraction | 850,000 | 309,000 | 323,000 | **2.8x** | **2.6x** |
| Multiplication (scalar) | 1,119,000 | 458,000 | 444,000 | **2.4x** | **2.5x** |
| Division (scalar) | 988,000 | 319,000 | — | **3.1x** | — |
| Division (ratio) | 3,674,000 | 334,000 | — | **11.0x** | — |
| Negation | 1,316,000 | 521,000 | — | **2.5x** | — |

### Comparison Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `==` (same value) | 1,841,000 | 264,000 | 305,000 | **7.0x** | **6.0x** |
| `==` (different value) | 1,817,000 | 274,000 | 300,000 | **6.6x** | **6.1x** |
| `==` (different currency) | 1,530,000 | 158,000 | 181,000 | **9.7x** | **8.5x** |
| `>` | 1,830,000 | 326,000 | 327,000 | **5.6x** | **5.6x** |
| `<=>` | 1,897,000 | 324,000 | 329,000 | **5.9x** | **5.8x** |
| `.hash` | 4,041,000 | 1,225,000 | 1,253,000 | **3.3x** | **3.2x** |

### Formatting / String Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `to_s` (amount 123.45) | 243,000 | 115,000 | 115,000 | **2.1x** | **2.1x** |
| `inspect` (amount 123.45) | 2,358,000 | 964,000 | 911,000 | **2.4x** | **2.6x** |
| `to_json` (amount 123.45) | 2,022,000 | — | 106,000 | — | **19.0x** |

### Numeric Conversion

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `to_i` | 11,680,000 | 559,000 | 531,000 | **20.9x** | **22.0x** |
| `to_f` | 7,420,000 | 400,000 | 518,000 | **18.6x** | **14.3x** |
| `to_d` | 2,126,000 | 559,000 | 577,000 | **3.8x** | **3.7x** |
| `to_r` | 12,237,000 | N/A | N/A | — | — |

### Currency Lookup

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `for_code` / `find` | 5,320,000 | 1,260,000 | 1,371,000 | **4.2x** | **3.9x** |

### Split & Allocation

| Scenario | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| Split 6 ways (small) | 339,000 | 71,000 | 77,000 | **4.8x** | **4.4x** |
| Split 1830 ways (small) | 2,064 | 227 | 308 | **9.1x** | **6.7x** |
| Split 6 ways (large) | 295,000 | 75,000 | 76,000 | **3.9x** | **3.9x** |
| Split 1830 ways (large) | 1,598 | 270 | 239 | **5.9x** | **6.7x** |
| Allocate [1,2,3] (small) | 356,000 | 109,000 | 124,000 | **3.3x** | **2.9x** |
| Allocate [1..60] (small) | 15,232 | 7,126 | 8,863 | **2.1x** | **1.7x** |

### High-Volume Transaction Simulation

| Metric | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| Time (50k transactions) | 568ms | 1,589ms | 646ms | **2.8x faster** | **2.3x faster** |
| Throughput | 88,000/s | 31,000/s | 77,000/s | **2.8x** | **2.3x** |

## Benchhmark Categories

### 1. Competitive Benchmark
**Purpose**: Compares Minting performance against the Money gem
- Object creation comparison
- Arithmetic operation comparison
- Memory usage comparison
- High-volume transaction simulation
- Precision accuracy comparison

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

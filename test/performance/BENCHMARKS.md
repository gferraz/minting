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
| `Money.new` / `Mint.money` | 1,307,000 | — | — | — | — |
| `from_amount` / `Mint.money` | 1,307,000 | 580,000 | 605,000 | **2.3x** | **2.2x** |
| `from_subunits` / `Money.new(cents)` | 1,307,000 | 580,000 | 605,000 | **2.3x** | **2.2x** |
| `.dollars` syntax | 1,307,000 | — | — | — | — |

### Arithmetic Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| Addition | 1,188,000 | — | — | — | — |
| Subtraction | 879,000 | 329,000 | — | **2.7x** | — |
| Multiplication (scalar) | 1,160,000 | 475,000 | — | **2.4x** | — |
| Division (scalar) | 1,043,000 | 335,000 | — | **3.1x** | — |
| Division (ratio) | 4,009,000 | 357,000 | — | **11.2x** | — |
| Negation | 1,423,000 | 544,000 | — | **2.6x** | — |

### Comparison Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `==` (same value) | 2,032,000 | — | 307,000 | — | **6.6x** |
| `==` (different value) | 2,219,000 | — | 316,000 | — | **7.0x** |
| `==` (different currency) | 1,780,000 | — | 179,000 | — | **9.9x** |
| `>` | 1,557,000 | — | 333,000 | — | **4.7x** |
| `<=>` | 1,909,000 | — | 345,000 | — | **5.5x** |
| `.hash` | 4,282,000 | — | 1,320,000 | — | **3.2x** |

### Formatting / String Operations

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `to_s` | 297,000 | — | 114,000 | — | **2.6x** |
| `inspect` | 2,505,000 | — | 1,042,000 | — | **2.4x** |
| `to_json` | 2,163,000 | — | 113,000 | — | **19.1x** |

### Numeric Conversion

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `to_i` | 11,656,000 | 580,000 | 605,000 | **20.1x** | **19.3x** |
| `to_f` | 7,491,000 | 562,000 | 595,000 | **13.3x** | **12.6x** |
| `to_d` | 2,325,000 | 626,000 | 651,000 | **3.7x** | **3.6x** |
| `to_r` | 13,599,000 | N/A | N/A | — | — |

### Currency Lookup

| Operation | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| `for_code` / `find` | 4,657,000 | — | 1,510,000 | — | **3.1x** |

### Split & Allocation

| Scenario | Minting | Money gem | Minting vs Money |
|---|---|---|---|
| Split 6 ways (small) | 352,000 | 78,000 | **4.5x** |
| Split 1830 ways (small) | 2,200 | 304 | **7.2x** |
| Split 6 ways (large) | 314,000 | 79,000 | **4.0x** |
| Split 1830 ways (large) | 1,900 | 308 | **6.2x** |
| Allocate [1,2,3] (small) | 353,000 | 134,000 | **2.6x** |
| Allocate [1..60] (small) | 21,000 | 9,200 | **2.3x** |

### High-Volume Transaction Simulation

| Metric | Minting | Money gem | Shopify Money | Minting vs Money | Minting vs Shopify |
|---|---|---|---|---|---|
| Time (50k transactions) | 282ms | 681ms | 646ms | **2.4x faster** | **2.3x faster** |
| Throughput | 177,000/s | 73,000/s | 77,000/s | **2.4x** | **2.3x** |

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

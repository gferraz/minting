# Performance Testing Guide 🚀

This directory contains comprehensive performance benchmarks for the Minting gem.

## Quick Start

```bash
rake bench:all            # Run tests for bench:all
rake bench:competitive    # Run tests for bench:competitive
rake bench:core           # Run tests for bench:core
rake bench:memory         # Run tests for bench:memory
rake bench:regression     # Run tests for bench:regression

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

## Interpreting Results

### Benchmark IPS Results
```
Calculating -------------------------------------
        operation_name     123.456k i/100ms
-------------------------------------------------
        operation_name       1.234M (± 2.3%) i/s -      6.789M
```
- **i/100ms**: Iterations per 100 milliseconds (warmup measurement)
- **i/s**: Final iterations per second
- **(± X%)**: Standard deviation percentage
- Higher numbers are better

### Memory Analysis Results
```
--- Object Creation ---
Allocated objects:
  T_OBJECT: 1000
  T_IMEMO: 50
  T_STRING: 25
```
- Shows objects allocated by type
- Lower allocation numbers are generally better
- Watch for unexpected allocations

### Comparative Results  
```
Comparison Example:
      Mint addition:  1.234M i/s
     Money addition:  0.987M i/s - 1.25x slower
```
- Shows relative performance between libraries
- Higher multiplier means the baseline (first entry) is faster

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

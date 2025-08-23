# Performance Testing Guide 🚀

This directory contains comprehensive performance benchmarks for the Minting gem.

## Quick Start

```bash
# Run all performance tests  
BENCH=true rake bench:performance

# Run specific benchmark categories
BENCH=true ruby -Ilib:test -r ./test/test_helper test/performance/core_operations_benchmark.rb
BENCH=true ruby -Ilib:test -r ./test/test_helper test/performance/memory_benchmark.rb
BENCH=true ruby -Ilib:test -r ./test/test_helper test/performance/algorithm_benchmark.rb
BENCH=true ruby -Ilib:test -r ./test/test_helper test/performance/competitive_benchmark.rb

# Run regression tests (Minitest::Benchmark)
rake bench:regression

# Run competitive analysis against Money gem
BENCH=true rake bench:competitive
```

## Test Categories

### 1. Core Operations Benchmark (`core_operations_benchmark.rb`)
**Purpose**: Measures basic operation performance
- Money creation with different data types
- Arithmetic operations (+, -, *, /, abs)  
- Comparison operations (==, <=>, >, hash)
- Currency lookup and registration

**Key Metrics**: Operations per second for each operation type

### 2. Memory Benchmark (`memory_benchmark.rb`)
**Purpose**: Analyzes memory allocation and garbage collection
- Object allocation patterns
- Memory retention testing (leak detection)
- Garbage collection pressure analysis
- Large-scale operation memory usage

**Key Metrics**: 
- Object allocation counts by type
- GC statistics (major/minor GC counts)
- Memory stability over time

### 3. Algorithm Benchmark (`algorithm_benchmark.rb`)
**Purpose**: Tests allocation and splitting algorithm performance
- Split performance with different amounts and split sizes
- Allocation performance with various proportion patterns
- Precision edge cases with different currencies
- Remainder distribution scenarios
- Pathological edge cases

**Key Metrics**: 
- Performance vs. data size scaling
- Accuracy of allocation results
- Edge case handling performance

### 4. Competitive Benchmark (`competitive_benchmark.rb`)
**Purpose**: Compares Minting performance against the Money gem
- Object creation comparison
- Arithmetic operation comparison
- Memory usage comparison
- High-volume transaction simulation
- Precision accuracy comparison

**Key Metrics**: 
- Relative performance ratios
- Memory allocation differences
- Precision accuracy comparisons

### 5. Regression Benchmark (`regression_benchmark.rb`)
**Purpose**: Detects performance regressions using Minitest::Benchmark
- Ensures operations maintain expected Big-O complexity
- Constant time operation verification
- Linear scaling validation
- Memory stability testing

**Key Metrics**: 
- Performance complexity validation (constant/linear)
- Regression detection over time

## Environment Variables

- `BENCH=true` - Required to run benchmark tests (they're skipped by default)
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
Comparison:
      Mint addition:  1.234M i/s
     Money addition:  0.987M i/s - 1.25x slower
```
- Shows relative performance between libraries
- Higher multiplier means the baseline (first entry) is faster

## Performance Targets

Based on typical Ruby money library benchmarks:

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

## Troubleshooting

### Tests Skipping
If benchmarks are being skipped, ensure `BENCH=true` is set:
```bash
BENCH=true ruby -Ilib:test test/performance/core_operations_benchmark.rb
```

### Missing Dependencies
Some benchmarks require additional gems:
```bash
gem install benchmark-ips ruby-prof money bigdecimal
```

### Ruby Version Compatibility  
Performance characteristics may vary between Ruby versions. Current testing focuses on Ruby 3.2+.

## Best Practices

### Running Benchmarks
1. **Consistent Environment**: Run on same machine/Ruby version
2. **Minimal Background Load**: Close other applications  
3. **Multiple Runs**: Results can vary, run several times
4. **Baseline Comparison**: Always compare against previous versions

### Interpreting Results
1. **Focus on Relative Performance**: Absolute numbers depend on hardware
2. **Look for Trends**: Performance degradation over time
3. **Memory vs Speed Tradeoffs**: Sometimes slower is more memory efficient
4. **Real-World Relevance**: Benchmark scenarios should match actual usage

### Performance Regression Detection
1. **Automate Regression Tests**: Run `rake bench:regression` in CI
2. **Set Performance Budgets**: Define acceptable performance thresholds
3. **Monitor Memory Usage**: Watch for memory leaks in long-running tests
4. **Profile Before Optimizing**: Use ruby-prof to identify bottlenecks

## Contributing Performance Tests

When adding new performance tests:

1. **Use Descriptive Names**: Test method names should be clear
2. **Skip by Default**: Use `skip unless ENV['BENCH']`
3. **Include Setup**: Prepare test data in setup methods
4. **Test Edge Cases**: Include boundary conditions
5. **Document Expected Results**: Add comments for expected performance characteristics
6. **Consider Memory Impact**: Test both speed and memory usage

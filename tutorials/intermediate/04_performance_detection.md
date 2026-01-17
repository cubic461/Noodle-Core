# Tutorial 04: Performance Regression Detection with Noodle v3

## 🎯 Learning Objectives

After completing this tutorial, you will:
- ✅ Understand what performance regression is and why it matters
- ✅ Configure performance detection in NIP v3
- ✅ Run benchmarks and analyze performance changes
- ✅ Set appropriate performance thresholds
- ✅ Interpret regression reports
- ✅ Prevent performance degradation in production

**Prerequisites:**
- Completed Tutorial 03 (Parallel Execution)
- Familiarity with benchmarking concepts
- Basic understanding of statistical analysis

**Estimated Time:** 50-65 minutes

---

## 📚 What is Performance Regression?

### The Problem: Silent Performance Degradation

You've optimized your code, tests pass, but is it **actually faster**?

```
Scenario: Memory Optimization

Before: 100ms per operation ✅
After:  150ms per operation ❌ (50% slower!)

Tests pass, but performance is degraded!
```

**Real-World Impact:**
- 💸 **Higher costs:** More server resources needed
- 😤 **Poor UX:** Slower response times
- 📉 **Lost revenue:** E-commerce sites lose sales
- 🔥 **Cascading failures:** Slowdowns cause timeouts

### The Solution: Automated Performance Detection

NIP v3 automatically detects performance regressions **before** they reach production:

```python
from noodlecore.improve.performance import PerformanceDetector

detector = PerformanceDetector()
report = detector.detect_regression(baseline, patch, task_id, candidate_id)

if report.overall_verdict == "fail":
    print(f"❌ CRITICAL: {report.regression_count} regressions detected!")
    print(f"Slowest: {report.slowest_metric} (+{report.slowest_degradation}%)")
else:
    print(f"✅ PASS: Performance maintained or improved")
```

---

## 🔧 How It Works: Benchmark Comparison

### Benchmark Formats Supported

NIP v3 supports multiple benchmark formats:

#### Python (pytest-benchmark)

```python
# benchmark_example.py
import pytest

@pytest.mark.benchmark(group="operations")
def test_performance(benchmark):
    result = benchmark(my_function, test_data)
    assert result == expected_value
```

**Run:** `pytest --benchmark-only`

**Output:**
```
---------- benchmark: 2 tests -----------
Name (time in ms)         Min       Max      Mean
-----------------------------------------------------------------
test_performance         10.2      15.3      12.5
test_baseline            8.5       12.1      10.2
-----------------------------------------------------------------
```

#### JavaScript (benchmark.js)

```javascript
// benchmark.js
const Benchmark = require('benchmark');

const suite = new Benchmark.Suite();

suite
.add('MyFunction', () => {
  myFunction(testData);
})
.add('Baseline', () => {
  baselineFunction(testData);
})
.on('cycle', (event) => {
  console.log(String(event.target));
})
.run();
```

**Run:** `node benchmark.js`

**Output:**
```
MyFunction x 98,765 ops/sec ±1.23% (85 runs sampled)
Baseline x 112,345 ops/sec ±1.15% (92 runs sampled)
```

#### Go (built-in)

```go
// benchmark_test.go
func BenchmarkMyFunction(b *testing.B) {
    for i := 0; i < b.N; i++ {
        MyFunction(testData)
    }
}
```

**Run:** `go test -bench=. -benchmem`

**Output:**
```
BenchmarkMyFunction-8    100000    10.2 ns/op    64 B/op    4 allocs/op
```

---

## 🚀 Quick Start: Detect Performance Regression

### Step 1: Configure Performance Detection

Update `noodle.json`:

```json
{
  "improve": {
    "version": "3.0.0",
    "performanceDetectionEnabled": true,
    "performance": {
      "criticalThreshold": 50.0,
      "highThreshold": 20.0,
      "mediumThreshold": 10.0,
      "lowThreshold": 5.0,
      "minABTestConfidence": 0.8
    }
  }
}
```

**Thresholds Explained:**
- **Critical (50%):** Reject immediately
- **High (20%):** Strong warning
- **Medium (10%):** Warning
- **Low (5%):** Informational

### Step 2: Create Performance Test

Create `tests/test_performance.py`:

```python
import pytest
from noodlecore.improve.performance import PerformanceDetector, BenchmarkRunner

class TestPerformanceDetection:
    
    def test_python_benchmark(self):
        """Test Python benchmark detection."""
        # Run baseline benchmark
        baseline_results = BenchmarkRunner.run_benchmark(
            format="pytest-benchmark",
            path="benchmarks/",
            test_file="test_baseline.py"
        )
        
        # Run patch benchmark
        patch_results = BenchmarkRunner.run_benchmark(
            format="pytest-benchmark",
            path="benchmarks/",
            test_file="test_patch.py"
        )
        
        # Detect regression
        detector = PerformanceDetector()
        report = detector.detect_regression(
            baseline=baseline_results,
            patch=patch_results,
            task_id="PERF_001",
            candidate_id="cand_001"
        )
        
        # Assert no critical regression
        assert report.overall_verdict != "fail", "Critical regression detected!"
        
        # Print results
        print(f"\n📊 Performance Report:")
        print(f"Verdict: {report.overall_verdict}")
        print(f"Regressions: {report.regression_count}")
        if report.regression_count > 0:
            print(f"⚠️  {report.slowest_metric}: +{report.slowest_degradation}%")
```

### Step 3: Run Performance Detection

```bash
pytest tests/test_performance.py -v
```

**Expected Output:**
```
📊 Performance Report:
Verdict: pass
Regressions: 0
✅ No performance regression detected!
```

---

## ⚙️ Advanced Configuration

### Metric-Specific Thresholds

Different metrics have different thresholds:

```json
{
  "improve": {
    "performance": {
      "criticalThreshold": 50.0,
      "highThreshold": 20.0,
      "thresholds": {
        "latency": {
          "critical": 100.0,  // 100% slower = reject
          "high": 50.0,
          "medium": 25.0,
          "low": 10.0
        },
        "throughput": {
          "critical": 50.0,   // 50% less = reject
          "high": 25.0,
          "medium": 15.0,
          "low": 5.0
        },
        "memory": {
          "critical": 100.0,  // 100% more = reject
          "high": 50.0,
          "medium": 25.0,
          "low": 10.0
        }
      }
    }
  }
}
```

### Statistical Significance

Ensure performance differences are statistically significant:

```python
from noodlecore.improve.performance import PerformanceDetector

detector = PerformanceDetector(
    min_confidence=0.95,  # 95% confidence required
    min_sample_size=10    // At least 10 iterations
)

report = detector.detect_regression(baseline, patch, task_id, candidate_id)

if report.confidence < detector.min_confidence:
    print(f"⚠️  Low confidence: {report.confidence:.2%}")
    print("Run more iterations for accurate results")
```

---

## 🎯 Best Practices

### 1. Use Realistic Workloads

```python
# ✅ GOOD: Realistic data size
test_data = generate_realistic_test_data(size=1_000_000)

# ❌ BAD: Too small, not representative
test_data = [1, 2, 3]  # Only 3 items!
```

### 2. Warm Up First

```python
# Run warmup iterations
for _ in range(3):
    my_function(test_data)

# Now measure
start = time.time()
my_function(test_data)
elapsed = time.time() - start
```

### 3. Run Multiple Iterations

```python
import numpy as np

times = []
for _ in range(10):
    start = time.time()
    my_function(test_data)
    times.append(time.time() - start)

mean_time = np.mean(times)
std_dev = np.std(times)
print(f"Mean: {mean_time:.3f}s ± {std_dev:.3f}s")
```

### 4. Monitor Resources

```python
import psutil
import os

process = psutil.Process(os.getpid())

# Memory before
mem_before = process.memory_info().rss / 1024 / 1024  # MB

# Run function
my_function(test_data)

# Memory after
mem_after = process.memory_info().rss / 1024 / 1024  # MB

print(f"Memory delta: {mem_after - mem_before:.2f} MB")
```

---

## 🐛 Common Mistakes

### Mistake 1: Micro-Benchmarks

**Problem:** Benchmarking trivial code

```python
# ❌ BAD: Trivial operation
def test_addition():
    assert 1 + 1 == 2  # Too fast, not meaningful
```

**Solution:** Benchmark realistic workloads

```python
# ✅ GOOD: Realistic workload
def test_database_query():
    result = benchmark(db.query, complex_query)
    assert result.count == expected_count
```

### Mistake 2: Ignoring Variance

**Problem:** Single measurement

```python
# ❌ BAD: One measurement
start = time.time()
my_function()
print(f"Time: {time.time() - start}s")  # May be outlier
```

**Solution:** Multiple measurements with statistics

```python
# ✅ GOOD: Statistical analysis
import statistics

times = [time_function() for _ in range(10)]
mean_time = statistics.mean(times)
median_time = statistics.median(times)
print(f"Mean: {mean_time:.3f}s, Median: {median_time:.3f}s")
```

### Mistake 3: Cold Start Effects

**Problem:** First run is slower (cold cache, JIT compilation)

```python
# ❌ BAD: Include cold start
times = []
for i in range(10):
    start = time.time()
    my_function()
    times.append(time.time() - start)
# First iteration may be much slower!
```

**Solution:** Warmup + discard first iterations

```python
# ✅ GOOD: Warmup first
for _ in range(3):  # Warmup
    my_function()

times = []
for _ in range(10):  # Measurement
    start = time.time()
    my_function()
    times.append(time.time() - start)
```

---

## 📊 Interpreting Regression Reports

### Report Structure

```python
RegressionReport(
    overall_verdict="pass",
    regression_count=0,
    improvements_count=2,
    metrics={
        "operation_latency": MetricComparison(
            baseline_mean=100.0,
            patch_mean=95.0,
            percent_change=-5.0,  # Negative = improvement
            severity=Severity.NONE
        ),
        "memory_usage": MetricComparison(
            baseline_mean=50.0,
            patch_mean=45.0,
            percent_change=-10.0,  # Improvement
            severity=Severity.IMPROVEMENT
        )
    },
    confidence=0.98,
    recommendations=["Performance improved! Consider deploying."]
)
```

### Severity Levels

| Severity | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | >50% degradation | ❌ Reject immediately |
| **HIGH** | 20-50% degradation | ⚠️  Strong warning, review |
| **MEDIUM** | 10-20% degradation | ⚠️  Warning, consider |
| **LOW** | 5-10% degradation | ℹ️  Informational |
| **NONE** | <5% change | ✅ Acceptable |
| **IMPROVEMENT** | Performance gain | 🎉 Bonus! |

---

## ✅ Exercise: Detect Performance Regression

Your turn! Implement performance detection for a real optimization.

**Scenario:** You've optimized a sorting algorithm. Verify it's actually faster.

**Task:**
1. Create baseline benchmark
2. Create optimized benchmark
3. Detect regression
4. Interpret results

**Template:**

```python
# TODO: Implement this
from noodlecore.improve.performance import PerformanceDetector, BenchmarkRunner

def test_sorting_optimization():
    # TODO: Create baseline benchmark
    baseline = BenchmarkRunner.run_benchmark(
        format="pytest-benchmark",
        path="benchmarks/",
        test_file="test_sort_baseline.py"
    )
    
    # TODO: Create optimized benchmark
    patch = BenchmarkRunner.run_benchmark(
        format="pytest-benchmark",
        path="benchmarks/",
        test_file="test_sort_optimized.py"
    )
    
    # TODO: Detect regression
    detector = PerformanceDetector()
    report = detector.detect_regression(
        baseline=baseline,
        patch=patch,
        task_id="SORT_001",
        candidate_id="optimized_sort"
    )
    
    # TODO: Interpret and print results
    print(f"Verdict: {report.overall_verdict}")
    print(f"Change: {report.metrics['sort_time'].percent_change:.2f}%")
```

---

## 🎓 Summary

In this tutorial, you learned:

✅ **What performance regression** is and why it matters  
✅ **How to configure** performance detection in NIP v3  
✅ **Supported benchmark formats:** Python, JavaScript, Go  
✅ **How to set** appropriate performance thresholds  
✅ **Best practices** for accurate benchmarking  
✅ **How to interpret** regression reports  

**Key Takeaways:**
- 📊 Performance regression = silent killer of user experience
- 🎯 Set thresholds based on **impact** (latency vs throughput)
- 🧪 Use **realistic workloads** and **multiple iterations**
- 📈 Use **statistical analysis** for confidence
- ⚠️ **Always** test performance before deploying

---

## 🚀 Next Steps

- **Tutorial 05:** Multi-Candidate Comparison
- **Tutorial 06:** A/B Testing
- **Tutorial 07:** LLM Integration

**Continue Learning:** [Tutorial 05: Multi-Candidate Comparison](./05_multi_candidate_comparison.md)

---

**🍜 Keep your code fast with Noodle!**

Questions? [Open an Issue](https://github.com/cubic461/Noodle-Core/issues)

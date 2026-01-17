# Tutorial 06: A/B Testing with Noodle v3

## 🎯 Learning Objectives

After completing this tutorial, you will:
- ✅ Understand scientific A/B testing methodology
- ✅ Configure A/B testing in NIP v3
- ✅ Run statistical tests (warmup, measurement, cool-down)
- ✅ Interpret A/B test results with confidence intervals
- ✅ Set appropriate success criteria

**Prerequisites:**
- Completed Tutorial 05 (Multi-Candidate Comparison)
- Basic understanding of statistical hypothesis testing
- Familiarity with confidence intervals

**Estimated Time:** 55-70 minutes

---

## 📚 What is A/B Testing?

### The Problem: Is the Patch Really Better?

Tests pass, performance looks good, but is it **statistically significant**?

```
Baseline: 100ms ± 10ms
Patch:    95ms  ± 8ms

Is this 5ms improvement real, or just noise?
```

**Without A/B testing:**
- 😐 May deploy changes that aren't actually better
- 😐 May reject good changes due to variance
- 😐 No statistical confidence in decisions

### The Solution: Scientific A/B Testing

NIP v3 provides **rigorous statistical validation**:

```python
from noodlecore.improve.ab_testing import ABTestRunner, ABTestConfig

config = ABTestConfig(
    warmup_iterations=3,
    measurement_iterations=10,
    success_criteria="both_pass_and_improve"
)

summary = runner.run_test(baseline_worktree, patch_worktree, ["pytest"])

print(f"📊 A/B Test Result: {summary.verdict}")
print(f"📈 Confidence: {summary.confidence:.2%}")
print(f"✅ Improvement: {summary.improvement:+.2f}%")
```

---

## 🔧 How It Works: Test Phases

### Phase 1: Warmup (Stabilization)

**Purpose:** Stabilize the system, eliminate cold-start effects

```python
for _ in range(config.warmup_iterations):
    # Run tests, discard results
    run_tests(worktree)
```

**Duration:** 3-5 iterations

**Why:** First runs are slower (cold cache, JIT compilation)

---

### Phase 2: Measurement (Data Collection)

**Purpose:** Collect meaningful data for statistical analysis

```python
baseline_results = []
patch_results = []

for _ in range(config.measurement_iterations):
    # Run baseline
    baseline_results.append(run_baseline_tests())
    
    # Run patch
    patch_results.append(run_patch_tests())
```

**Duration:** 10-20 iterations (minimum for statistical significance)

**Why:** More iterations = higher confidence

---

### Phase 3: Cool-down (Cleanup)

**Purpose:** Clean up resources, ensure no state leakage

```python
# Cleanup worktrees
cleanup(baseline_worktree)
cleanup(patch_worktree)
```

**Duration:** 1-2 iterations

**Why:** Prepare system for next test

---

## 🚀 Quick Start: Your First A/B Test

### Step 1: Configure A/B Testing

Update `noodle.json`:

```json
{
  "improve": {
    "abTestingEnabled": true,
    "performance": {
      "requireABTestForHighRisk": true,
      "minABTestConfidence": 0.8
    },
    "ab_test": {
      "warmup_iterations": 3,
      "measurement_iterations": 10,
      "success_criteria": "both_pass_and_improve"
    }
  }
}
```

**Success Criteria Options:**
- `"both_pass"`: Both must pass tests
- `"b_improves"`: Patch must improve performance
- `"both_pass_and_improve"`: Both (default)

### Step 2: Create A/B Test Script

Create `examples/ab_test_example.py`:

```python
from noodlecore.improve.ab_testing import ABTestRunner, ABTestConfig
from noodlecore.improve.parallel import WorktreeManager

# Configure A/B test
config = ABTestConfig(
    warmup_iterations=3,
    measurement_iterations=10,
    success_criteria="both_pass_and_improve",
    min_confidence=0.8
)

# Create A/B test runner
runner = ABTestRunner(config)

# Define test commands
test_commands = ["pytest", "-v", "--benchmark-only"]

# Run A/B test
summary = runner.run_test(
    baseline_worktree=baseline_wt,
    patch_worktree=patch_wt,
    commands=test_commands
)

# Print results
print("🔬 A/B Test Results")
print("=" * 60)
print(f"Verdict: {summary.verdict}")
print(f"Confidence: {summary.confidence:.2%}")
print(f"Baseline mean: {summary.baseline_mean:.3f}ms")
print(f"Patch mean: {summary.patch_mean:.3f}ms")
print(f"Improvement: {summary.improvement:+.2f}%")
print(f"P-value: {summary.p_value:.4f}")

if summary.verdict == "pass":
    print("✅ Patch is statistically significantly better!")
else:
    print("❌ Patch did not meet success criteria")
```

**Expected Output:**
```
🔬 A/B Test Results
============================================================
Verdict: pass
Confidence: 85.00%
Baseline mean: 100.000ms
Patch mean: 92.000ms
Improvement: -8.00%
P-value: 0.0032
✅ Patch is statistically significantly better!
```

---

## ⚙️ Advanced Configuration

### Statistical Tests

NIP v3 supports multiple statistical tests:

#### 1. T-Test (Default)

```python
config = ABTestConfig(
    statistical_test="t_test",
    measurement_iterations=10
)
```

**Use when:** Normal distribution, sufficient sample size

---

#### 2. Mann-Whitney U Test

```python
config = ABTestConfig(
    statistical_test="mann_whitney",
    measurement_iterations=20
)
```

**Use when:** Non-normal distribution, small sample size

---

#### 3. Bootstrap Test

```python
config = ABTestConfig(
    statistical_test="bootstrap",
    measurement_iterations=100,
    bootstrap_samples=1000
)
```

**Use when:** Distribution unknown, high confidence needed

---

### Confidence Intervals

Calculate confidence intervals for metrics:

```python
summary = runner.run_test(baseline_wt, patch_wt, commands)

# Print confidence intervals
print(f"Baseline CI: {summary.baseline_ci}")
print(f"Patch CI: {summary.patch_ci}")

# Example output:
# Baseline CI: [95.2ms, 104.8ms] (95% confidence)
# Patch CI: [89.1ms, 94.9ms] (95% confidence)
```

---

## 🎯 Best Practices

### 1. Use Appropriate Sample Size

```python
# ✅ GOOD: Sufficient sample size
measurement_iterations = max(10, calculate_sample_size(
    effect_size=0.2,
    power=0.8,
    alpha=0.05
))

# ❌ BAD: Too few iterations
measurement_iterations = 2  # Not statistically valid!
```

### 2. Check Assumptions

```python
# Test for normal distribution
if is_normal(baseline_results) and is_normal(patch_results):
    test = "t_test"
else:
    test = "mann_whitney"

config = ABTestConfig(statistical_test=test)
```

### 3. Account for Multiple Testing

```python
# Bonferroni correction for multiple metrics
alpha = 0.05 / len(metrics)
config = ABTestConfig(min_confidence=1 - alpha)
```

---

## 🐛 Common Mistakes

### Mistake 1: Insufficient Warmup

**Problem:** Cold start effects skew results

```python
# ❌ BAD: No warmup
config = ABTestConfig(warmup_iterations=0)
```

**Solution:** Always warm up

```python
# ✅ GOOD: Sufficient warmup
config = ABTestConfig(warmup_iterations=3)
```

### Mistake 2: Too Few Measurements

**Problem:** Low statistical power

```python
# ❌ BAD: Too few measurements
config = ABTestConfig(measurement_iterations=3)
```

**Solution:** Minimum 10 measurements

```python
# ✅ GOOD: Sufficient measurements
config = ABTestConfig(measurement_iterations=10)
```

### Mistake 3: Ignoring Variance

**Problem:** Only looking at means

```python
# ❌ BAD: Only mean
if patch_mean < baseline_mean:
    print("Improvement!")
```

**Solution:** Consider variance and confidence

```python
# ✅ GOOD: Statistical test
if summary.verdict == "pass" and summary.confidence > 0.8:
    print("Statistically significant improvement!")
```

---

## ✅ Exercise: A/B Test Optimization

Your turn! Perform A/B test on an optimization.

**Scenario:** Compare two sorting algorithms

**Task:**
1. Configure A/B test
2. Run warmup, measurement, cool-down
3. Analyze results
4. Determine statistical significance

**Template:**

```python
# TODO: Implement this
from noodlecore.improve.ab_testing import ABTestRunner, ABTestConfig

# TODO: Configure test
config = ABTestConfig(
    warmup_iterations=3,
    measurement_iterations=10,
    success_criteria="both_pass_and_improve"
)

# TODO: Run test
runner = ABTestRunner(config)
summary = runner.run_test(baseline_wt, patch_wt, ["pytest"])

# TODO: Analyze
print(f"Verdict: {summary.verdict}")
print(f"Confidence: {summary.confidence:.2%}")
print(f"Improvement: {summary.improvement:+.2f}%")

# TODO: Determine if statistically significant
if summary.verdict == "pass" and summary.confidence > 0.8:
    print("✅ Deploy!")
else:
    print("❌ Not ready")
```

---

## 🎓 Summary

In this tutorial, you learned:

✅ **A/B testing** provides scientific validation  
✅ **3 test phases:** Warmup, Measurement, Cool-down  
✅ **Statistical tests:** T-test, Mann-Whitney, Bootstrap  
✅ **Confidence intervals** quantify uncertainty  
✅ **Best practices:** Sufficient iterations, check assumptions  

**Key Takeaways:**
- 🔬 A/B testing = **statistical confidence** in decisions
- 📊 Always include **warmup** to eliminate cold-start
- 🧪 Use **minimum 10 measurements** for validity
- 📈 **Confidence intervals** show uncertainty
- ✅ **Statistical significance** ≠ practical significance

---

## 🚀 Next Steps

- **Tutorial 07:** LLM Integration
- **Tutorial 08:** LSP Gate
- **Tutorial 09:** Automatic Rollback

**Continue Learning:** [Tutorial 07: LLM Integration](./07_llm_integration.md)

---

**🍜 Make data-driven decisions with Noodle!**

Questions? [Open an Issue](https://github.com/cubic461/Noodle-Core/issues)

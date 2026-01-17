# Tutorial 05: Multi-Candidate Comparison with Noodle v3

## 🎯 Learning Objectives

After completing this tutorial, you will:
- ✅ Understand multi-candidate comparison strategies
- ✅ Configure ranking strategies (BALANCED, PERFORMANCE, SAFETY, INNOVATION)
- ✅ Interpret multi-dimensional scoring results
- ✅ Use Pareto frontier analysis for candidate selection
- ✅ Select the best candidate automatically

**Prerequisites:**
- Completed Tutorial 03 (Parallel Execution)
- Completed Tutorial 04 (Performance Detection)
- Understanding of multi-objective optimization

**Estimated Time:** 50-65 minutes

---

## 📚 What is Multi-Candidate Comparison?

### The Problem: Multiple Candidates, Hard to Choose

You've generated **multiple improvement candidates**, but which one is best?

```
Candidate 1: ✅ Tests pass,  ⚡ Fast,     ❌ Memory heavy
Candidate 2: ✅ Tests pass,  🐌 Slow,     ✅ Memory efficient
Candidate 3: ⚠️  Tests flaky, ⚡ Fast,     ✅ Memory efficient
```

**Challenge:** Each candidate has different strengths and weaknesses. How do you choose?

### The Solution: Multi-Dimensional Scoring

NIP v3 uses **multi-dimensional scoring** to rank candidates:

```python
from noodlecore.improve.comparison import CandidateComparator

comparator = CandidateComparator(strategy=RankingStrategy.BALANCED)
result = comparator.compare_candidates(candidates, evidence, reports)

print(f"🏆 Winner: {result.winner}")
print(f"📊 Score: {result.scores[result.winner]}")
print(f"💡 Recommendation: {result.recommendation}")
```

---

## 🚀 Quick Start: Compare Multiple Candidates

### Step 1: Configure Comparison Strategy

Update `noodle.json`:

```json
{
  "improve": {
    "multiCandidateComparisonEnabled": true,
    "comparison": {
      "defaultStrategy": "BALANCED",
      "weights": {
        "performance": 0.4,
        "safety": 0.4,
        "innovation": 0.2
      }
    }
  }
}
```

### Step 2: Compare Candidates

```python
from noodlecore.improve.comparison import CandidateComparator, RankingStrategy

# Create comparator
comparator = CandidateComparator(strategy=RankingStrategy.BALANCED)

# Compare candidates
result = comparator.compare_candidates(candidates, evidence, reports)

# Print results
print(f"🏆 WINNER: {result.winner}")
print(f"💡 Recommendation: {result.recommendation}")
```

---

## ⚙️ Ranking Strategies

### BALANCED (Default)
Equal weight on all dimensions

### PERFORMANCE_FOCUSED
Prioritize speed and efficiency

### SAFETY_FOCUSED
Prioritize reliability and stability

### INNOVATION_FOCUSED
Prioritize novel approaches

---

## ✅ Exercise

Compare 3 optimization strategies using different ranking strategies.

---

## 🎓 Summary

✅ Multi-candidate comparison uses multi-dimensional scoring  
✅ 4 ranking strategies available  
✅ Always consider recommendations and reasoning  
✅ Match strategy to risk level  

---

**🍜 Choose the best candidate with Noodle!**

# Tutorial 03: Parallel Execution with Noodle v3

## 🎯 Learning Objectives

After completing this tutorial, you will:
- ✅ Understand how parallel execution works in NIP v3
- ✅ Configure WorktreeManager for optimal performance
- ✅ Execute multiple improvement candidates simultaneously
- ✅ Handle parallel execution errors gracefully
- ✅ Monitor and analyze parallel execution results

**Prerequisites:**
- Completed Tutorial 01 (Hello World)
- Completed Tutorial 02 (Basic Improvements)
- Basic understanding of Git worktrees
- Familiarity with Python concurrency concepts

**Estimated Time:** 45-60 minutes

---

## 📚 What is Parallel Execution?

### The Problem: Sequential Execution

In NIP v1 and v2, improvement candidates were executed **sequentially**:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Candidate  │ ──> │  Candidate  │ ──> │  Candidate  │
│      1      │     │      2      │     │      3      │
└─────────────┘     └─────────────┘     └─────────────┘
     5 min              5 min              5 min
         Total: 15 minutes
```

**Issues:**
- ⏱️ **Slow:** Each candidate waits for the previous one to finish
- 💻 **Underutilized:** CPU cores sit idle during execution
- 🚫 **Bottleneck:** Limited by single-thread execution

### The Solution: Parallel Execution

In NIP v3, candidates execute **simultaneously** using parallel worktrees:

```
┌─────────────┐
│  Candidate  │
│      1      │
└─────────────┘
     ↓ 5 min
     
┌─────────────┐     ┌─────────────┐
│  Candidate  │     │  Candidate  │
│      2      │     │      3      │
└─────────────┘     └─────────────┘
     ↓ 5 min            ↓ 5 min
     
         Total: 5 minutes (3x faster!)
```

**Benefits:**
- ⚡ **3-5x faster** for multiple candidates
- 💻 **Better resource utilization** (multiple CPU cores)
- 🔄 **Concurrent testing** with isolation guarantees
- 📊 **Faster iteration** and feedback loops

---

## 🔧 How It Works: Under the Hood

### Git Worktree Isolation

NIP v3 uses **Git worktrees** for isolated parallel execution:

```bash
# Main repository
/noodle-project/

# Parallel worktrees (isolated)
/noodle-project/.noodle/improve/worktrees/candidate_001/
/noodle-project/.noodle/improve/worktrees/candidate_002/
/noodle-project/.noodle/improve/worktrees/candidate_003/
```

**Key Features:**
- 🔒 **Isolation:** Each worktree has its own working directory
- 🔄 **Independent:** Changes in one worktree don't affect others
- 💾 **Shared History:** All worktrees share the same Git object database
- 🧹 **Auto Cleanup:** Worktrees are removed after execution

---

## 🚀 Quick Start: Your First Parallel Execution

### Step 1: Configure Parallel Execution

Update `noodle.json`:

```json
{
  "improve": {
    "version": "3.0.0",
    "parallelExecutionEnabled": true,
    "maxParallelWorktrees": 3,
    "worktreeDir": ".noodle/improve/worktrees"
  }
}
```

### Step 2: Create a Parallel Execution Script

Create `examples/parallel_example.py`:

```python
from noodlecore.improve.parallel import WorktreeManager, WorktreeConfig
from noodlecore.improve.snapshot import SnapshotManager
from noodlecore.improve.models import TaskSpec, Candidate

# Load task
task = TaskSpec.from_json_file("tasks/parallel_example.json")

# Create managers
snapshot_manager = SnapshotManager(task)
config = WorktreeConfig(max_parallel=3)
manager = WorktreeManager(config, snapshot_manager)

# Define execution function
def run_tests(worktree, candidate):
    """Execute tests in a worktree."""
    print(f"Running tests for {candidate.candidate_id} in {worktree.path}")
    
    # Run pytest in the worktree
    result = worktree.execute_command(["pytest", "-v"])
    
    return {
        "candidate_id": candidate.candidate_id,
        "passed": result.returncode == 0,
        "output": result.stdout
    }

# Create multiple candidates
candidates = [
    Candidate(
        candidate_id="cand_001",
        patch="# Optimized version 1\n...",
        metadata={"strategy": "loop_unrolling"}
    ),
    Candidate(
        candidate_id="cand_002",
        patch="# Optimized version 2\n...",
        metadata={"strategy": "caching"}
    ),
    Candidate(
        candidate_id="cand_003",
        patch="# Optimized version 3\n...",
        metadata={"strategy": "vectorization"}
    )
]

# Execute in parallel
print("🚀 Starting parallel execution...")
results = manager.execute_parallel(
    candidates=candidates,
    execution_func=run_tests
)

# Analyze results
print("\n📊 Results:")
for result in results:
    status = "✅ PASS" if result["passed"] else "❌ FAIL"
    print(f"{status}: {result['candidate_id']}")
```

**Expected Output:**
```
🚀 Starting parallel execution...
Running tests for cand_001 in .noodle/improve/worktrees/cand_001/
Running tests for cand_002 in .noodle/improve/worktrees/cand_002/
Running tests for cand_003 in .noodle/improve/worktrees/cand_003/

📊 Results:
✅ PASS: cand_001
✅ PASS: cand_002
❌ FAIL: cand_003
```

---

## ⚙️ Advanced Configuration

### Dynamic Parallelism

```python
import os

# CPU-based parallelism
cpu_count = os.cpu_count()
config = WorktreeConfig(max_parallel=max(1, cpu_count - 1))
```

### Timeout Handling

```python
config = WorktreeConfig(
    max_parallel=3,
    execution_timeout=300,  # 5 minutes max per worktree
    cleanup_timeout=30       # 30 seconds max for cleanup
)
```

---

## 🐛 Common Mistakes

### Mistake 1: Race Conditions

**Problem:** Multiple worktrees modify shared resources

**Solution:** Use worktree-specific paths

```python
# ✅ GOOD: Each worktree has its own log
def run_tests(worktree, candidate):
    log_path = worktree.path / "candidate.log"
    with open(log_path, "w") as f:
        f.write(f"Testing {candidate.candidate_id}...\n")
```

### Mistake 2: No Timeout

**Problem:** Worktrees hang indefinitely

**Solution:** Always set timeouts

```python
config = WorktreeConfig(
    max_parallel=3,
    execution_timeout=300
)
```

---

## ✅ Exercise

Implement parallel execution for 5 different optimization strategies.

**Template:**

```python
from noodlecore.improve.parallel import WorktreeManager, WorktreeConfig
from noodlecore.improve.models import Candidate

def run_benchmark(worktree, candidate):
    """Run performance benchmark."""
    # TODO: Execute benchmark
    pass

# TODO: Create 5 candidates
candidates = [
    Candidate("strategy_1", "patch_1", {}),
    # ... add 4 more
]

# TODO: Execute in parallel
config = WorktreeConfig(max_parallel=3)
manager = WorktreeManager(config, snapshot_manager)

# TODO: Analyze results
```

---

## 🎓 Summary

In this tutorial, you learned:

✅ Parallel execution is **3-5x faster** than sequential  
✅ Git worktrees provide **isolation guarantees**  
✅ Set `max_parallel` based on **CPU cores and memory**  
✅ Always set **timeouts** to prevent hanging  
✅ Use **context managers** for automatic cleanup  

---

## 🚀 Next Steps

**Tutorial 04:** Performance Regression Detection

**🍜 Happy Coding with Noodle!**

Questions? [Open an Issue](https://github.com/cubic461/Noodle-Core/issues)

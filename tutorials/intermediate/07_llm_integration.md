# Tutorial 07: LLM Integration with Noodle v3

## 🎯 Learning Objectives

After completing this tutorial, you will:
- ✅ Understand LLM integration in NIP v3
- ✅ Configure Z.ai GLM-4.7 as primary provider
- ✅ Set up fallback providers (OpenAI, Anthropic)
- ✅ Generate patches with AI
- ✅ Track costs and manage budgets
- ✅ Handle LLM errors gracefully

**Prerequisites:**
- Completed Tutorial 06 (A/B Testing)
- API key for Z.ai (or compatible provider)
- Understanding of LLM fundamentals

**Estimated Time:** 60-75 minutes

---

## 📚 What is LLM Integration?

### The Problem: Manual Patch Generation

Writing optimization patches manually is:
- 🐌 **Time-consuming:** Each patch takes hours
- 😫 **Error-prone:** Humans make mistakes
- 🎲 **Inconsistent:** Quality varies
- 📚 **Knowledge-intensive:** Requires expertise

### The Solution: AI-Powered Patch Generation

NIP v3 uses **Large Language Models** to generate patches automatically:

```python
from noodlecore.improve.llm_integration import LLMManager

llm = LLMManager()
result = llm.generate_patch(task, context)

print(f"🤖 AI-Generated Patch:")
print(result.patch)
print(f"✅ Confidence: {result.confidence:.2%}")
print(f"💰 Cost: ${result.metadata['cost_usd']:.4f}")
```

**Benefits:**
- ⚡ **Fast:** Patches in seconds
- 🎯 **Consistent:** Quality control
- 💡 **Creative:** Novel approaches
- 🌐 **Multilingual:** Z.ai supports Chinese + English

---

## 🔧 How It Works: Provider Architecture

### Primary Provider: Z.ai GLM-4.7

```python
class ZAIProvider(LLMProvider):
    """
    Z.ai GLM-4.7 - Bilingual, optimized for code
    - Input: ~$0.70 per 1M tokens
    - Output: ~$2.00 per 1M tokens
    - Context: 128K tokens
    """
    def generate_patch(self, task, context):
        # Call Z.ai API
        response = self.api.call(
            model="glm-4.7",
            messages=self._build_prompt(task, context),
            temperature=0.3
        )
        return self._parse_response(response)
```

### Fallback Providers

```python
llm = LLMManager(providers=[
    ZAIProvider(api_key=os.getenv("ZAI_API_KEY")),
    OpenAIProvider(api_key=os.getenv("OPENAI_API_KEY")),
    AnthropicProvider(api_key=os.getenv("ANTHROPIC_API_KEY"))
])

result = llm.generate_patch(task, context)

# If Z.ai fails, automatically falls back to OpenAI
# If OpenAI fails, automatically falls back to Anthropic
```

---

## 🚀 Quick Start: Your First AI-Generated Patch

### Step 1: Configure LLM Integration

Update `noodle.json`:

```json
{
  "improve": {
    "llmIntegrationEnabled": true,
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "temperature": 0.3,
      "maxTokens": 4096,
      "apiBase": "https://open.bigmodel.cn/api/paas/v4/chat/completions",
      "fallback": [
        {"provider": "openai", "model": "gpt-4-turbo"},
        {"provider": "anthropic", "model": "claude-3-sonnet"}
      ],
      "maxCostPerTask": 1.0,
      "dailyBudget": 10.0,
      "timeoutSeconds": 120
    }
  }
}
```

### Step 2: Set API Keys

```bash
# Z.ai (primary)
export ZAI_API_KEY="your-zai-key"

# OpenAI (fallback)
export OPENAI_API_KEY="your-openai-key"

# Anthropic (fallback)
export ANTHROPIC_API_KEY="your-anthropic-key"
```

### Step 3: Create LLM Patch Generator

Create `examples/llm_patch_example.py`:

```python
from noodlecore.improve.llm_integration import LLMManager
from noodlecore.improve.models import TaskSpec, TaskContext

# Load task
task = TaskSpec.from_json_file("tasks/optimize_function.json")

# Create context
context = TaskContext(
    repository_path=".",
    base_branch="main",
    target_files=["src/performance_critical.py"],
    constraints={
        "max_loc_changed": 100,
        "risk_level": "medium"
    }
)

# Create LLM manager
llm = LLMManager()

# Generate patch
print("🤖 Generating AI patch...")
result = llm.generate_patch(task, context)

# Display results
print("\n📋 Patch Generation Results")
print("=" * 60)
print(f"✅ Status: {result.status}")
print(f"🎯 Confidence: {result.confidence:.2%}")
print(f"💰 Cost: ${result.metadata['cost_usd']:.4f}")
print(f"📊 Tokens: {result.metadata['total_tokens']}")
print(f"⏱️  Time: {result.metadata['generation_time']:.2f}s")

print(f"\n🤖 AI-Generated Patch:")
print("-" * 60)
print(result.patch)

# Save patch
with open("patches/ai_generated.patch", "w") as f:
    f.write(result.patch)
print("\n✅ Patch saved to patches/ai_generated.patch")
```

**Expected Output:**
```
🤖 Generating AI patch...

📋 Patch Generation Results
============================================================
✅ Status: success
🎯 Confidence: 87.00%
💰 Cost: $0.0234
📊 Tokens: 1234
⏱️  Time: 3.45s

🤖 AI-Generated Patch:
------------------------------------------------------------
--- a/src/performance_critical.py
+++ b/src/performance_critical.py
@@ -1,6 +1,13 @@
 def process_data(data):
-    result = []
-    for item in data:
-        result.append(transform(item))
-    return result
+    # Optimized with list comprehension
+    return [transform(item) for item in data]

✅ Patch saved to patches/ai_generated.patch
```

---

## ⚙️ Advanced Configuration

### Cost Tracking

Track LLM spending:

```python
from noodlecore.improve.llm_integration import BudgetTracker

tracker = BudgetTracker(daily_budget=10.0)

# Check budget
remaining = tracker.get_remaining_budget()
print(f"💰 Remaining budget: ${remaining:.2f}")

# Generate patch
result = llm.generate_patch(task, context)

# Log cost
tracker.log_cost(result.metadata['cost_usd'])
print(f"💰 Cost this task: ${result.metadata['cost_usd']:.4f}")
print(f"💰 Total today: ${tracker.get_daily_spend():.2f}")
```

### Prompt Engineering

Customize prompts for better results:

```python
from noodlecore.improve.llm_integration import LLMManager

llm = LLMManager()

# Custom prompt template
custom_prompt = """
You are an expert code optimizer. Your task is to:
1. Analyze the code for performance bottlenecks
2. Propose optimizations that:
   - Reduce execution time by at least 20%
   - Maintain code readability
   - Add explanatory comments
3. Consider edge cases and error handling

Code to optimize:
{code}

Constraints:
{constraints}
"""

result = llm.generate_patch(
    task=task,
    context=context,
    prompt_template=custom_prompt
)
```

### Temperature Tuning

Control creativity:

```python
# Low temperature = more deterministic
result = llm.generate_patch(task, context, temperature=0.1)

# Medium temperature = balanced (default)
result = llm.generate_patch(task, context, temperature=0.3)

# High temperature = more creative
result = llm.generate_patch(task, context, temperature=0.7)
```

---

## 🎯 Best Practices

### 1. Use Cost Limits

```python
# ✅ GOOD: Set cost limits
llm = LLMManager(max_cost_per_task=1.0)

try:
    result = llm.generate_patch(task, context)
except CostExceededError:
    print("⚠️  Cost limit exceeded, falling back to template")
```

### 2. Handle Timeouts

```python
# ✅ GOOD: Set timeouts
llm = LLMManager(timeout=120)

try:
    result = llm.generate_patch(task, context)
except TimeoutError:
    print("⚠️  LLM timeout, using fallback provider")
```

### 3. Validate AI Outputs

```python
# ✅ GOOD: Always validate
result = llm.generate_patch(task, context)

# Validate syntax
if not is_valid_syntax(result.patch):
    print("❌ Invalid syntax, rejecting")
    return None

# Validate constraints
if exceeds_max_loc(result.patch, task.max_loc_changed):
    print("❌ Exceeds LOC limit, rejecting")
    return None

print("✅ AI patch validated")
```

---

## 🐛 Common Mistakes

### Mistake 1: No API Key

**Problem:** Missing or invalid API key

```python
# ❌ BAD: No API key
# export ZAI_API_KEY=""  # Empty!
```

**Solution:** Always set valid API key

```bash
# ✅ GOOD: Valid API key
export ZAI_API_KEY="sk-..."
```

### Mistake 2: Ignoring Costs

**Problem:** Uncontrolled LLM spending

```python
# ❌ BAD: No cost tracking
result = llm.generate_patch(task, context)
# How much did this cost?
```

**Solution:** Track costs

```python
# ✅ GOOD: Track costs
result = llm.generate_patch(task, context)
print(f"Cost: ${result.metadata['cost_usd']:.4f}")
```

### Mistake 3: Blind Trust

**Problem:** Deploying AI patches without review

```python
# ❌ BAD: No review
result = llm.generate_patch(task, context)
apply_patch(result.patch)  # Dangerous!
```

**Solution:** Always review

```python
# ✅ GOOD: Manual review
result = llm.generate_patch(task, context)
if manual_review(result.patch):
    apply_patch(result.patch)
```

---

## ✅ Exercise: Generate AI Patch

Your turn! Generate an AI-optimized patch.

**Scenario:** Optimize a database query function

**Task:**
1. Configure LLM integration
2. Generate patch with AI
3. Validate and review
4. Apply if approved

**Template:**

```python
# TODO: Implement this
from noodlecore.improve.llm_integration import LLMManager

# TODO: Create LLM manager
llm = LLMManager()

# TODO: Generate patch
result = llm.generate_patch(task, context)

# TODO: Validate
print(f"Confidence: {result.confidence:.2%}")
print(f"Cost: ${result.metadata['cost_usd']:.4f}")

# TODO: Review and apply
if result.confidence > 0.8:
    print("✅ High confidence, applying patch")
    apply_patch(result.patch)
else:
    print("⚠️  Low confidence, manual review needed")
```

---

## 🎓 Summary

In this tutorial, you learned:

✅ **LLM integration** enables automatic patch generation  
✅ **Z.ai GLM-4.7** is the primary provider (cost-effective)  
✅ **Fallback providers** ensure reliability  
✅ **Cost tracking** prevents budget overruns  
✅ **Validation** is essential for AI outputs  

**Key Takeaways:**
- 🤖 LLMs can **generate patches in seconds**
- 💰 **Cost tracking** is essential (~$0.001-0.01 per patch)
- 🎯 **Confidence scores** help decision-making
- ✅ Always **validate** AI-generated code
- 🔄 **Fallback providers** ensure reliability

---

## 🚀 Next Steps

- **Tutorial 08:** LSP Gate
- **Tutorial 09:** Automatic Rollback
- **Tutorial 10:** Analytics Dashboard

**Continue Learning:** [Tutorial 08: LSP Gate](./08_lsp_gate.md)

---

**🤖 Let AI improve your code with Noodle!**

Questions? [Open an Issue](https://github.com/cubic461/Noodle-Core/issues)

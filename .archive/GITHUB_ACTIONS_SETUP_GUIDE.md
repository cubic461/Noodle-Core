# 🚀 GitHub Actions Setup Guide - Step by Step

**Optie B: GitHub Actions Integration Testing**

---

## 📋 Overview

This guide will walk you through setting up and testing the GitHub Actions auto-migration workflow in a real repository.

---

## 🎯 What We're Building

```
GitHub Repository
├── .github/workflows/auto-migration.yml  ← GitHub Actions workflow
├── python-scripts/                       ← Python files to migrate
├── golden-tests/                         ← Generated regression tests
├── go-output/                            ← Generated Go code
└── README.md                             ← With build status badge
```

---

## 📝 Step 1: Create GitHub Repository

### 1.1 Go to GitHub
- Open browser → `https://github.com/new`
- Or: Click `+` → `New repository`

### 1.2 Fill Repository Details
```
Repository name: noodle-migration-test
Description: Testing automated Python to Go migration
Visibility: Public (for badge visibility)
```

### 1.3 Initialize Repository
- ☑️ Add a README file
- ☐ Add .gitignore (choose Python)
- ☐ Choose a license (MIT)

### 1.4 Create Repository
- Click **Create repository**

---

## 🔐 Step 2: Setup Repository Secrets

### 2.1 Go to Repository Settings
```
Repository → Settings → Secrets and variables → Actions
```

### 2.2 Add Required Secrets

#### Secret #1: GH_TOKEN
```
Name: GH_TOKEN
Value: your_personal_access_token_here
```

**How to create Personal Access Token (PAT):**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click **Generate new token**
3. Select scopes:
   - ☑️ `repo` (full control of private repositories)
   - ☑️ `workflow` (update GitHub Action workflows)
   - ☑️ `actions:write` (write access to Actions)
4. Click **Generate token**
5. Copy the token (you won't see it again!)

#### Secret #2: GOOGLE_API_KEY (Optional)
```
Name: GOOGLE_API_KEY
Value: your_google_api_key
```

**Note:** Only needed if using AI code generation features

---

## 📁 Step 3: Upload Migration Files

### 3.1 Clone Repository Locally
```bash
git clone https://github.com/YOUR-USERNAME/noodle-migration-test.git
cd noodle-migration-test
```

### 3.2 Copy Required Files

Create this directory structure:

```
noodle-migration-test/
├── .github/workflows/auto-migration.yml     ← We'll create this next
├── migration/
│   ├── source_harness/
│   │   ├── __init__.py
│   │   ├── trace_format.py
│   │   ├── golden_test_format.py
│   │   └── runtime_adapters/
│   │       ├── __init__.py
│   │       └── python_adapter.py
│   └── generate_golden_test.py
└── examples/
    ├── simple_file_processor.py
    └── sample_input.csv
```

### 3.3 Add Test Python Scripts

Create `examples/simple_file_processor.py`:

```python
#!/usr/bin/env python3
"""Simple file processor for testing migration."""

import sys

def process_file(input_path, output_path):
    """Convert file to uppercase."""
    with open(input_path, 'r') as f:
        content = f.read()
    
    processed = content.upper()
    
    with open(output_path, 'w') as f:
        f.write(processed)
    
    print(f"[OK] Processed {input_path} → {output_path}")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python simple_file_processor.py <input> <output>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    success = process_file(input_file, output_file)
    sys.exit(0 if success else 1)
```

Create `examples/sample_input.csv`:

```csv
name,email,phone
john,john@example.com,555-1234
jane,jane@example.com,555-5678
```

### 3.4 Commit and Push

```bash
git add .
git commit -m "Initial migration setup with test files"
git push origin main
```

---

## ⚙️ Step 4: Create GitHub Actions Workflow

### 4.1 Create Workflow File

Create `.github/workflows/auto-migration.yml`:

```yaml
name: Auto-Python-to-Go Migration

on:
  push:
    branches: [ main, development ]
    paths:
      - '**.py'
      - '.github/workflows/auto-migration.yml'
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Allow manual trigger

jobs:
  auto-migration:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      actions: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install pytest psutil
          
      - name: Detect changed Python files
        id: detect
        run: |
          echo "Changed Python files:"
          git diff --name-only HEAD~1 HEAD | grep '\.py$' || echo "No Python files changed"
          
      - name: Install Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
          
      - name: Run migration
        id: migrate
        run: |
          echo "Running Python migration..."
          cd migration
          python generate_golden_test.py generate \
            --script "../examples/simple_file_processor.py" \
            --args "sample_input.csv output.csv"
          echo "Migration completed"
          
      - name: Upload trace artifacts
        uses: actions/upload-artifact@v3
        with:
          name: migration-traces
          path: migration/test_trace_*.json
          
      - name: Upload golden tests
        uses: actions/upload-artifact@v3
        with:
          name: golden-tests
          path: migration/golden_tests/
          
      - name: Create summary
        run: |
          echo "## Migration Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "✅ Successfully migrated Python scripts" >> $GITHUB_STEP_SUMMARY
          echo "📊 Generated golden tests" >> $GITHUB_STEP_SUMMARY
          echo "📁 Uploaded artifacts" >> $GITHUB_STEP_SUMMARY
          
      - name: Create Pull Request
        if: github.ref == 'refs/heads/main'
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
        run: |
          echo "Creating PR for migration results..."
          gh pr create \
            --title "[Auto-Migration] Python to Go Migration" \
            --body "This PR contains auto-generated Go code from Python scripts." \
            --head feature/auto-migration \
            --base main
```

### 4.2 Commit and Push Workflow

```bash
git add .github/workflows/auto-migration.yml
git commit -m "Add auto-migration workflow"
git push origin main
```

---

## 🔍 Step 5: Test the Workflow

### 5.1 Manual Trigger

1. Go to Actions tab
2. Click **Auto-Python-to-Go Migration**
3. Click **Run workflow** → **Run workflow**

### 5.2 Automatic Trigger

Edit a Python file and push:

```bash
echo "# Test comment" >> examples/simple_file_processor.py
git add examples/simple_file_processor.py
git commit -m "Test: trigger auto-migration"
git push origin main
```

### 5.3 Monitor Workflow

**Actions Tab:**
```
✅ Auto-Python-to-Go Migration #1
   ✓ Checkout
   ✓ Setup Python
   ✓ Install Go
   ✓ Run migration
   ✓ Upload artifacts
```

---

## ✅ Step 6: Verify Results

### 6.1 Check Artifacts

**Actions Tab** → **Artifacts:**
- `migration-traces` - Execution traces
- `golden-tests` - Generated regression tests

Download and inspect artifacts.

### 6.2 Check Generated Files

In repository (after workflow completes):
```
✅ migration/golden_tests/ - Golden tests created
✅ migration/test_trace_*.json - Traces saved
✅ go-output/ - Go code generated (when implemented)
```

### 6.3 Check Pull Request

If PR was created:
```
✅ New PR created
✅ Contains migration summary
✅ Shows diff with generated code
```

---

## 🔧 Step 7: Add Build Status Badge

### 7.1 Get Badge Markdown

Go to Actions → Auto-Python-to-Go Migration → Create status badge

```
[![Auto-Migration](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml/badge.svg)](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml)
```

### 7.2 Add to README.md

```markdown
# Noodle Migration Test

[![Auto-Migration](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml/badge.svg)](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml)

This repository demonstrates automated Python to Go migration using GitHub Actions.
```

---

## 🐛 Troubleshooting

### Issue: Workflow Not Triggering
**Solution:**
- Check file paths in `paths:` filter
- Verify you're pushing to correct branch
- Check Actions tab for errors

### Issue: GH_TOKEN Not Working
**Solution:**
- Verify token has correct permissions (repo, workflow)
- Check secret name matches exactly `GH_TOKEN`
- Re-generate token if needed

### Issue: Python Import Errors
**Solution:**
- Check all required files are in migration/ directory
- Add `__init__.py` files to make packages
- Test imports locally first

### Issue: Artifacts Not Uploading
**Solution:**
- Check artifact paths are correct
- Verify file patterns match actual files
- Check workflow logs for errors

---

## 📊 Success Metrics

Your workflow is successful when:

- [x] Workflow starts automatically on Python changes
- [x] All steps complete without errors
- [x] Traces are captured and saved
- [x] Golden tests are generated
- [x] Artifacts are uploaded
- [x] Build status badge shows ✅ (passing)
- [ ] PR is created (when fully implemented)
- [ ] Go code is generated (when fully implemented)

---

## 🎯 Next Steps After Setup

1. **Test with More Complex Scripts**
   - Add scripts with dependencies
   - Test error handling
   - Performance benchmarks

2. **Implement Go Scaffolding**
   - Add Go code generation
   - Compile and test Go code
   - Compare outputs

3. **Add More Features**
   - Multi-script batch processing
   - Performance comparisons
   - Custom reporting

4. **Production Deployment**
   - Test on real projects
   - Optimization for large repos
   - Security hardening

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Artifacts Documentation](https://docs.github.com/en/actions/advanced-guides/storing-workflow-data-as-artifacts)

---

**Questions or Issues?** Check the main [GITHUB_ACTIONS_GUIDE.md](noodle-core/src/migration/GITHUB_ACTIONS_GUIDE.md)

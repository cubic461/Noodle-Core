# Test Repository for Noodle Migration

[![Auto-Migration](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml/badge.svg)](https://github.com/YOUR-USERNAME/noodle-migration-test/actions/workflows/auto-migration.yml)

This repository demonstrates automated Python to Go migration using GitHub Actions.

## 🚀 Features

- ✅ **Automatic Detection**: Detects changes to Python files
- ✅ **Trace Capture**: Records execution traces with call graphs and I/O logs
- ✅ **Golden Test Generation**: Creates regression tests from traces
- ✅ **Go Scaffolding**: Generates Go code from Python scripts (coming soon)
- ✅ **Pull Request Creation**: Automatically creates PRs with migration results

## 📁 Repository Structure

```
noodle-migration-test/
├── .github/workflows/
│   └── auto-migration.yml      # GitHub Actions workflow
├── examples/                    # Test Python scripts
│   ├── simple_file_processor.py
│   └── sample_input.csv
├── migration/                   # Migration system
│   ├── generate_golden_test.py
│   └── source_harness/
└── golden_tests/               # Generated tests
```

## 🔧 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/YOUR-USERNAME/noodle-migration-test.git
cd noodle-migration-test
```

### 2. Add Your Python Scripts
Add Python scripts to the `examples/` directory:
```bash
# Example script
echo '
def hello():
    print("Hello, World!")

if __name__ == "__main__":
    hello()
' > examples/my_script.py
```

### 3. Commit and Push
```bash
git add examples/my_script.py
git commit -m "Add new Python script"
git push origin main
```

### 4. Watch the Magic Happen
GitHub Actions will automatically:
1. Detect your Python file changes
2. Capture execution traces
3. Generate golden tests
4. Create a summary report
5. (Future) Generate Go code

## 📊 Workflow Triggers

The migration workflow runs when:
- ✏️ **Push to main**: Full migration with PR creation
- 🔀 **Push to development**: Test migration without PR
- 🤖 **Manual trigger**: From Actions tab
- 🎯 **Pull request**: When Python files are modified

## 🧪 Test Cases

### TC1: Simple File Processing
```bash
# Input
name,email
john,john@example.com

# Processed Output
NAME,EMAIL
JOHN,JOHN@EXAMPLE.COM
```

### TC2: Function Tracing
- Captures function calls
- Records I/O operations
- Saves execution traces

## 📈 Results

### Artifacts Generated
- 📊 `migration-traces`: Execution traces
- 🏆 `golden-tests`: Regression test suite
- ⚡ `go-output`: Generated Go code

### Pull Request Contents
- ✅ Migration summary
- 📊 Performance comparison
- 🔍 Code diff
- 🧪 Test results

## 🐛 Troubleshooting

### Workflow Not Running
1. Check file paths in `.github/workflows/auto-migration.yml`
2. Verify you're pushing Python files (`.py`)
3. Check Actions tab for errors

### Import Errors
1. Verify all migration files are in `migration/` directory
2. Check Python version compatibility
3. Review workflow logs

## 📚 Documentation

- [GitHub Actions Setup Guide](path/to/setup_guide.md)
- [Migration System Documentation](noodle-core/src/migration/README.md)
- [GITHUB_ACTIONS_GUIDE.md](noodle-core/src/migration/GITHUB_ACTIONS_GUIDE.md)

## 🤝 Contributing

Feel free to add test cases and examples!

1. Fork the repository
2. Add your test case
3. Submit a pull request

## 📝 License

MIT License - See LICENSE file for details.

---

**Built with ❤️ using Noodle Migration System**

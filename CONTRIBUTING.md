# Contributing to NIP

Thank you for your interest in contributing to NIP (Network Implementation Protocol)! We welcome contributions from everyone, whether you're fixing bugs, adding features, improving documentation, or sharing ideas.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Getting Help](#getting-help)

## Getting Started

### Ways to Contribute

There are many ways to contribute to NIP:

- 🐛 **Report bugs** - Help us identify and fix issues
- 💡 **Suggest features** - Share your ideas for improvements
- 📖 **Improve documentation** - Make NIP easier to understand
- 🔧 **Fix bugs** - Submit pull requests to fix identified issues
- ✨ **Add features** - Implement new functionality
- 🧪 **Write tests** - Improve test coverage
- 💬 **Help others** - Answer questions in the community

All contributions are valued and appreciated!

## Development Setup

### Prerequisites

- **Python 3.9 or higher**
- **Git** for version control
- A code editor (VS Code, PyCharm, or similar)

### Setting Up Your Development Environment

1. **Fork the repository**

   ```
   Click the "Fork" button in the top-right corner of the GitHub page
   ```

2. **Clone your fork**

   ```bash
   git clone https://github.com/YOUR_USERNAME/NIP.git
   cd NIP
   ```

3. **Create a virtual environment**

   ```bash
   # On Windows
   python -m venv venv
   venv\Scripts\activate

   # On macOS/Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

4. **Install dependencies**

   ```bash
   pip install -e ".[dev]"
   ```

5. **Install pre-commit hooks** (recommended)

   ```bash
   pre-commit install
   ```

6. **Run tests to verify your setup**

   ```bash
   pytest
   ```

### Development Workflow

1. **Create a new branch** for your work

   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes** following our code style guidelines

3. **Write tests** for your changes

4. **Run tests** to ensure everything passes

   ```bash
   pytest
   ```

5. **Format your code** using our style tools

   ```bash
   black .
   isort .
   ```

## Code Style Guidelines

We follow industry-standard Python coding practices:

### Python Style

- **PEP 8** compliance - Use [Black](https://black.readthedocs.io/) for automatic formatting
- **Type hints** - Include type annotations for all public functions
- **Docstrings** - Use Google-style docstrings
- **Maximum line length** - 100 characters (Black default)

### Example Code Style

```python
from typing import List, Optional

def process_data(items: List[str], threshold: Optional[int] = None) -> dict:
    """Process a list of items and return aggregated results.
    
    Args:
        items: List of item identifiers to process
        threshold: Optional minimum threshold for filtering
        
    Returns:
        Dictionary containing processed results with keys:
        - 'success': Count of successfully processed items
        - 'failed': Count of failed items
        
    Raises:
        ValueError: If items list is empty
    """
    if not items:
        raise ValueError("Items list cannot be empty")
    
    # Implementation here
    return {"success": 0, "failed": 0}
```

### Naming Conventions

- **Functions and variables**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private members**: `_leading_underscore`

### File Organization

```
nip/
├── core/           # Core functionality
├── utils/          # Utility functions
├── tests/          # Test files
├── docs/           # Documentation
└── examples/       # Usage examples
```

### Import Order

1. Standard library imports
2. Third-party imports
3. Local imports
4. Each group separated by a blank line

```python
import os
import sys

import requests
from typing import List

from nip.core import processor
from nip.utils import helper
```

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

### Examples

```
feat(core): add support for custom protocols

Implement custom protocol handlers to allow users to extend
NIP with their own protocol implementations.

Closes #123
```

```
fix(network): resolve connection timeout issue

The previous timeout value was too short for slow networks.
Increased default timeout to 30 seconds.

Fixes #456
```

## Pull Request Process

### Before Submitting

1. **Update documentation** if your changes affect user-facing functionality
2. **Add tests** for new functionality or bug fixes
3. **Update CHANGELOG.md** with your changes
4. **Run all tests** to ensure they pass
5. **Format your code** using Black and isort

### Submitting a Pull Request

1. **Push your changes** to your fork

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a pull request** on GitHub
   - Use the PR template (automatically provided)
   - Fill in all required sections
   - Link related issues

3. **Wait for review** - Maintainers will review your PR
   - Address review feedback promptly
   - Ask questions if anything is unclear

4. **Approval and merge** - Once approved, your PR will be merged

### PR Review Process

- **Automated checks** must pass (tests, linting, etc.)
- **At least one maintainer approval** is required
- **All review comments** should be addressed
- **CI/CD pipeline** must be green

### After Merge

- 🎉 **Congratulations!** Your contribution is now part of NIP
- Consider **helping review** other contributors' PRs
- **Stay engaged** with issues and discussions

## Testing Requirements

### Test Coverage

We aim for **80%+ test coverage**. All new code must include tests.

### Writing Tests

Use `pytest` for testing:

```python
import pytest
from nip.core import processor

def test_process_data_with_valid_input():
    """Test that valid data is processed correctly."""
    items = ["item1", "item2", "item3"]
    result = processor.process_data(items)
    assert result["success"] == 3
    assert result["failed"] == 0

def test_process_data_with_empty_list():
    """Test that empty list raises ValueError."""
    with pytest.raises(ValueError):
        processor.process_data([])
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=nip --cov-report=html

# Run specific test file
pytest tests/test_processor.py

# Run specific test
pytest tests/test_processor.py::test_process_data_with_valid_input
```

### Test Organization

```
tests/
├── unit/           # Unit tests for individual components
├── integration/    # Integration tests for component interaction
└── fixtures/       # Test fixtures and data
```

## Getting Help

### Resources

- **Documentation**: [Read the Docs](https://nip.readthedocs.io/)
- **Issues**: [GitHub Issues](https://github.com/block/nip/issues)
- **Discussions**: [GitHub Discussions](https://github.com/block/nip/discussions)
- **Discord**: Join our community server

### Asking Questions

When asking for help:

1. **Search first** - Check if your question has been answered
2. **Be specific** - Provide details about your issue
3. **Share code** - Include relevant code snippets
4. **Use appropriate channels** - Issues for bugs, Discussions for questions

## Code of Conduct

Please review and follow our [Code of Conduct](CODE_OF_CONDUCT.md). We strive to provide a welcoming and inclusive community for everyone.

## Recognition

Contributors will be recognized in:
- The CONTRIBUTORS.md file
- Release notes for significant contributions
- Our documentation and website

Thank you for contributing to NIP! 🚀

---

**Need help?** Check out our [SUPPORT.md](SUPPORT.md) for resources and community channels.

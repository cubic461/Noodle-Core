# NOODLE PROJECT UNIFIED MAKEFILE
# Professional build system for NoodleCore project

.PHONY: all clean test install build-dev build-prod build-all help setup-hooks lint format type-check security-check pre-commit-all sonar-scan sonar-local quality-report quality-dashboard quality-check
.DEFAULT_GOAL := help

# Project structure
PROJECT_NAME := noodle
CORE_DIR := noodle-core
DOCS_DIR := docs
EXAMPLES_DIR := examples
SCRIPTS_DIR := scripts
TESTS_DIR := tests
CONFIG_DIR := config
DOCKER_DIR := docker

# Environment variables
PYTHON := python3
PIP := pip3
NODE := node
NPM := npm

# Build targets
all: install test build-dev

# Help target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Project Structure:"
	@echo "  noodle-core/     - Core NoodleCore implementation"
	@echo "  docs/            - Documentation"
	@echo "  examples/        - Example code"
	@echo "  scripts/         - Build and utility scripts"
	@echo "  tests/           - Test files"
	@echo "  config/          - Configuration files"
	@echo "  docker/          - Docker configuration"

# Installation targets
install: ## Install all dependencies
	@echo "Installing dependencies..."
	@$(PYTHON) -m pip install --upgrade pip
	@if [ -f requirements.txt ]; then $(PIP) install -r requirements.txt; fi
	@if [ -f $(CORE_DIR)/requirements.txt ]; then $(PIP) install -r $(CORE_DIR)/requirements.txt; fi
	@echo "Dependencies installed"

install-core: ## Install core dependencies only
	@echo "Installing core dependencies..."
	@if [ -f $(CORE_DIR)/requirements.txt ]; then $(PIP) install -r $(CORE_DIR)/requirements.txt; fi
	@echo "Core dependencies installed"

# Development targets
build-dev: ## Build for development
	@echo "Building for development..."
	@cd $(CORE_DIR) && $(PYTHON) setup.py develop
	@echo "Development build complete"

build-core-dev: ## Build core for development
	@echo "Building core (development)..."
	@cd $(CORE_DIR) && $(PYTHON) setup.py develop
	@echo "Core development build complete"

# Production targets
build-prod: ## Build for production
	@echo "Building for production..."
	@$(MAKE) build-core-prod
	@echo "Production build complete"

build-core-prod: ## Build core for production
	@echo "Building core (production)..."
	@cd $(CORE_DIR) && $(PYTHON) setup.py sdist bdist_wheel
	@echo "Core production build complete"

# Test targets
test: ## Run all tests
	@echo "Running all tests..."
	@if [ -d $(TESTS_DIR) ]; then cd $(TESTS_DIR) && $(PYTHON) -m pytest -v; fi
	@echo "All tests complete"

test-core: ## Run core tests
	@echo "Running core tests..."
	@if [ -d $(CORE_DIR) ]; then cd $(CORE_DIR) && $(PYTHON) -m pytest -v; fi
	@echo "Core tests complete"

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@if [ -d $(TESTS_DIR)/integration ]; then cd $(TESTS_DIR)/integration && $(PYTHON) -m pytest -v; fi
	@echo "Integration tests complete"

# Utility targets
clean: ## Clean all build artifacts
	@echo "Cleaning build artifacts..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@rm -rf build/ dist/ .coverage .pytest_cache/
	@echo "Clean complete"

lint: ## Run all linters
	@echo "Running all linters..."
	@$(PYTHON) -m flake8 noodle-core/ src/ tests/ --max-line-length=100 --extend-ignore=E203,W503 || true
	@$(PYTHON) -m pylint noodle-core/ src/ --max-line-length=100 --disable=C0111,R0903 || true
	@$(PYTHON) -m pydocstyle noodle-core/ src/ --convention=google || true
	@echo "Linting complete"

format: ## Format code with black and isort
	@echo "Formatting code with black and isort..."
	@$(PYTHON) -m black noodle-core/ src/ tests/ --line-length=100
	@$(PYTHON) -m isort noodle-core/ src/ tests/ --profile black --line-length 100
	@echo "Code formatted"

format-check: ## Check code formatting
	@echo "Checking code formatting..."
	@$(PYTHON) -m black --check noodle-core/ src/ tests/ --line-length=100
	@$(PYTHON) -m isort --check-only noodle-core/ src/ tests/ --profile black --line-length 100
	@echo "Format check complete"

type-check: ## Run mypy type checking
	@echo "Running mypy type checking..."
	@$(PYTHON) -m mypy noodle-core/ src/ --ignore-missing-imports --strict
	@echo "Type check complete"

security-check: ## Run bandit security scanning
	@echo "Running bandit security scanning..."
	@$(PYTHON) -m bandit -r noodle-core/ src/ -f json -o bandit-report.json || true
	@$(PYTHON) -m bandit -r noodle-core/ src/
	@echo "Security check complete"

docs: ## Generate Sphinx documentation
	@echo "Generating Sphinx documentation..."
	@bash $(SCRIPTS_DIR)/build_docs.sh
	@echo "Documentation generated"

docs-serve: ## Serve documentation locally
	@echo "Serving documentation locally..."
	@bash $(SCRIPTS_DIR)/serve_docs.sh

docs-clean: ## Clean documentation build artifacts
	@echo "Cleaning documentation build artifacts..."
	@rm -rf $(DOCS_DIR)/build
	@echo "Documentation cleaned"

docs-install: ## Install documentation dependencies
	@echo "Installing documentation dependencies..."
	@if [ -f $(DOCS_DIR)/requirements.txt ]; then $(PIP) install -r $(DOCS_DIR)/requirements.txt; fi
	@echo "Documentation dependencies installed"

# Docker targets
docker-build: ## Build Docker images
	@echo "Building Docker images..."
	@if [ -f $(DOCKER_DIR)/Dockerfile ]; then docker build -f $(DOCKER_DIR)/Dockerfile -t noodle-core:latest .; fi
	@echo "Docker images built"

docker-run: ## Run Docker containers
	@echo "Running Docker containers..."
	@if [ -f $(DOCKER_DIR)/docker-compose.yml ]; then docker-compose -f $(DOCKER_DIR)/docker-compose.yml up -d; fi
	@echo "Docker containers running"

# CI/CD targets
ci-test: ## Run CI tests
	@echo "Running CI tests..."
	@$(MAKE) test
	@echo "CI tests complete"

# Development workflow
dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	@$(MAKE) install
	@$(MAKE) build-dev
	@$(MAKE) test
	@echo "Development environment ready"

release: ## Create release
	@echo "Creating release..."
	@$(MAKE) test
	@$(MAKE) build-prod
	@echo "Release ready"

# Developer tooling targets
setup-hooks: ## Install pre-commit and git hooks
	@echo "Installing developer hooks..."
	@bash scripts/setup_precommit.sh
	@bash scripts/setup_git_hooks.sh
	@echo "Developer hooks installed"

pre-commit-all: ## Run all pre-commit hooks on all files
	@echo "Running all pre-commit hooks..."
	@if command -v pre-commit &> /dev/null; then \
		pre-commit run --all-files; \
	else \
		echo "pre-commit not installed. Run 'make setup-hooks' first."; \
		exit 1; \
	fi
	@echo "All pre-commit hooks passed"

pre-commit-update: ## Update pre-commit hooks to latest versions
	@echo "Updating pre-commit hooks..."
	@if command -v pre-commit &> /dev/null; then \
		pre-commit autoupdate; \
	else \
		echo "pre-commit not installed. Run 'make setup-hooks' first."; \
		exit 1; \
	fi
	@echo "Pre-commit hooks updated"

pre-commit-clean: ## Clean pre-commit cached environments
	@echo "Cleaning pre-commit cache..."
	@if command -v pre-commit &> /dev/null; then \
		pre-commit clean; \
	else \
		echo "pre-commit not installed."; \
		exit 1; \
	fi
	@echo "Pre-commit cache cleaned"

quality-check: ## Run all quality checks (lint, format, type, security)
	@echo "Running all quality checks..."
	@$(MAKE) format-check
	@$(MAKE) lint
	@$(MAKE) type-check
	@$(MAKE) security-check
	@echo "All quality checks passed"

fix-style: ## Auto-fix style issues
	@echo "Auto-fixing style issues..."
	@$(MAKE) format
	@echo "Style issues fixed"

# Quality metrics targets
sonar-scan: ## Run SonarQube scan
	@echo "Running SonarQube scan..."
	@if [ -n "$$SONAR_TOKEN" ]; then \
		sonar-scanner -Dsonar.qualitygate.wait=true; \
	else \
		echo "SONAR_TOKEN environment variable not set"; \
		echo "Set it with: export SONAR_TOKEN=your-token"; \
		exit 1; \
	fi

sonar-local: ## Start local SonarQube instance
	@echo "Starting local SonarQube..."
	@bash scripts/setup_sonarqube.sh

sonar-stop: ## Stop local SonarQube instance
	@echo "Stopping local SonarQube..."
	@docker-compose -f docker-compose-sonarqube.yml down

sonar-setup: ## Setup SonarQube quality gates
	@echo "Setting up SonarQube quality gates..."
	@bash scripts/setup_quality_gates.sh

quality-report: ## Generate quality report
	@echo "Generating quality report..."
	@python3 scripts/quality_metrics.py --output quality_metrics.json
	@python3 scripts/generate_quality_report.py quality_metrics.json --format all --output quality_report

quality-dashboard: ## Generate quality dashboard data
	@echo "Generating quality dashboard..."
	@python3 scripts/generate_dashboard.py quality_metrics.json --output dashboard_data.json --update-markdown docs/QUALITY_DASHBOARD.md

quality-check: ## Check quality gate status
	@echo "Checking quality gate status..."
	@python3 scripts/quality_metrics.py --quiet
	@echo "Quality gate status: $$?"

quality-all: ## Run all quality checks and generate reports
	@echo "Running complete quality analysis..."
	@$(MAKE) quality-report
	@$(MAKE) quality-dashboard
	@$(MAKE) sonar-scan
	@echo "Quality analysis complete"

coverage-badge: ## Generate coverage badge
	@echo "Generating coverage badge..."
	@python3 << 'EOF'
import json
try:
    with open('coverage.json', 'r') as f:
        data = json.load(f)
        coverage = data['totals']['percent_covered']
        color = 'brightgreen' if coverage >= 80 else 'yellow' if coverage >= 70 else 'red'
        print(f"![Coverage](https://img.shields.io/badge/Coverage-{coverage:.1f}%25-{color})")
except FileNotFoundError:
    print("Coverage data not found. Run tests first.")
EOF

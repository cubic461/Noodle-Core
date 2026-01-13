# Makefile for generated_go_project
# Generated 2025-12-14 20:37:14

.PHONY: help build test clean run install

# Build variables
BINARY_NAME := generated_go_project
GO_FILES := $(wildcard *.go)

# Go variables
GOCMD := go
GOBUILD := $(GOCMD) build
GOCLEAN := $(GOCMD) clean
GOTEST := $(GOCMD) test
GOMOD := $(GOCMD) mod
GOGET := $(GOCMD) get
BINARY_UNIX := $(BINARY_NAME)_unix

# Default target
all: help

# Show help
help:
	@echo "Available targets:"
	@echo "  build     - Build the application"
	@echo "  test      - Run tests"
	@echo "  run       - Run the application"
	@echo "  clean     - Clean build artifacts"
	@echo "  install   - Install dependencies"
	@echo "  deps      - Same as install"

# Install dependencies
install deps:
	@echo "Installing dependencies..."
	$(GOMOD) tidy
	$(GOGET) -v ./...

# Build the application
build:
	@echo "Building $(BINARY_NAME)..."
	$(GOBUILD) -o $(BINARY_NAME) -v

# Run the application
run:
	@echo "Running $(BINARY_NAME)..."
	$(GOCMD) run .

# Run tests
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

# Clean build artifacts
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_UNIX)

# Build for Linux
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_UNIX) -v

# Format code
fmt:
	$(GOCMD) fmt ./...

# Vet code
vet:
	$(GOCMD) vet ./...

# Lint (requires golangci-lint)
lint:
	@command -v golangci-lint >/dev/null 2>&1 || { \
		echo "golangci-lint not installed. Install with:"; \
		echo "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
		exit 1; \
	}
	golangci-lint run

# Download dependencies
deps-download:
	$(GOMOD) download

# Verify dependencies
deps-verify:
	$(GOMOD) verify

# Show module info
mod-info:
	$(GOMOD) graph

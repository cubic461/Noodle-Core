# Makefile for Go Migration Template
# Provides convenient targets for building, testing, and running

.PHONY: all build run clean test help install lint format

# Default target
all: build

# Build the application
build:
	go build -o csv-processor main.go

# Install the application
install:
	go install

# Run the application with default args
run:
	go run main.go

# Run with verbose output
run-verbose:
	go run main.go -v

# Test using input.csv in local directory
test: build
	./csv-processor -v

# Clean all generated files
clean:
	rm -f csv-processor
	rm -f output.csv

# Format code
format:
	go fmt ./...

# Download dependencies
deps:
	go mod download
	go mod tidy

# Display help
help:
	@echo "Go Migration Template - Makefile Commands"
	@echo "========================================"
	@echo ""
	@echo "Build Commands:"
	@echo "  build        - Compile the Go binary"
	@echo "  install      - Install to GOPATH"
	@echo "  clean        - Remove generated files"
	@echo ""
	@echo "Run Commands:"
	@echo "  run          - Run the program with default arguments"
	@echo "  run-verbose  - Run with verbose output"
	@echo "  test         - Build and run with verbose output"
	@echo ""
	@echo "Development Commands:"
	@echo "  format       - Format code using gofmt"
	@echo "  deps         - Download and tidy dependencies"
	@echo "  lint         - Run linter (if available)"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build   # Create csv-processor binary"
	@echo "  ./csv-processor -i input.csv -o output.csv -v"
	@echo "  make clean   # Remove binary and output files"

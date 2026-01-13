# Multi-stage build for Noodle runtime
FROM python:3.12-slim-bullseye as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies needed for building
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install Python dependencies
COPY pyproject.toml README.md ./
COPY src/noodle/pyproject.toml ./src/noodle/
COPY src/noodle/README.md ./src/noodle/

# Install build dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install build twine

# Build the package
RUN python -m build

# Runtime stage
FROM python:3.12-slim-bullseye as runtime

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install runtime system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy built packages from builder stage
COPY --from=builder /dist /dist

# Install the package and runtime dependencies
RUN pip install --no-cache-dir /dist/*.whl

# Create non-root user
RUN useradd --create-home --shell /bin/bash noodle
USER noodle

# Set working directory
WORKDIR /app

# Copy example files and configuration
COPY --from=builder src/noodle/examples/ ./examples/
COPY --from=builder src/noodle/config/ ./config/

# Expose port for web interface (if applicable)
EXPOSE 8080

# Default command
CMD ["python", "-m", "noodle", "--help"]

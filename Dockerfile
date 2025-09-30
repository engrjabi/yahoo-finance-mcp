# Build stage
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim AS builder

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Copy project files
COPY pyproject.toml uv.lock* ./
COPY server.py ./

# Install the project's dependencies using uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -e .

# Runtime stage
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git && \
    rm -rf /var/lib/apt/lists/*

# Install uv and mcp-proxy
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"
RUN uv tool install git+https://github.com/sparfenyuk/mcp-proxy

WORKDIR /app

# Copy from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app .

# Copy application code
COPY . .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    HOST=0.0.0.0 \
    PORT=8567

# Expose port
EXPOSE 8567

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8567/health || exit 1

# Start with mcp-proxy
CMD ["sh", "-c", "mcp-proxy --host=${HOST} --port=${PORT} --stateless uv run server.py"]

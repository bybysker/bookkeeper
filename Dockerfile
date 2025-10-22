# Use uv's ARM64 Python base image
FROM --platform=linux/arm64 ghcr.io/astral-sh/uv:python3.11-bookworm

WORKDIR /app

# Copy uv files and source code (needed for editable install)
COPY pyproject.toml uv.lock ./
COPY src ./src

# Install dependencies (including strands-agents)
RUN uv sync --frozen --no-cache

# Expose port
EXPOSE 8080

# Run application
CMD ["uv", "run", "uvicorn", "bookkeeper.api.app:app", "--host", "0.0.0.0", "--port", "8080"]
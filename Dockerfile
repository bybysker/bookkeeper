# Use uv's ARM64 Python base image
FROM --platform=linux/arm64 ghcr.io/astral-sh/uv:python3.11-bookworm

WORKDIR /app

# Copy uv files
COPY pyproject.toml uv.lock ./

# Install dependencies (including strands-agents)
RUN uv sync --frozen --no-cache

# Copy agent file
COPY main_agent.py ./

# Copy agents folder
COPY agents ./agents

# Expose port
EXPOSE 8080

# Run application
CMD ["uv", "run", "uvicorn", "main_agent:app", "--host", "0.0.0.0", "--port", "8080"]
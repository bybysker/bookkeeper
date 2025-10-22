# Migration Guide: Codebase Reorganization

This document outlines the changes made during the codebase reorganization.

## Summary

The codebase has been reorganized following Python packaging best practices with a **src-layout** structure. This improves maintainability, testability, and professional structure.

## What Changed

### Directory Structure

**Before:**
```
bookkeeper/
├── agents/              # Agent implementations
├── utils/               # Utilities
├── main_agent.py        # Main application
├── test_bedrock.py      # Tests in root
├── invoke_agent.py      # Scripts in root
└── deploy_agent.py
```

**After:**
```
bookkeeper/
├── src/bookkeeper/      # Main package (src-layout)
│   ├── api/            # FastAPI application
│   ├── agents/         # Agent implementations
│   ├── core/           # Configuration
│   └── knowledge_base/ # KB management
├── tests/              # Test suite
├── scripts/            # Utility scripts
└── [config files]      # Root level configs
```

### File Moves

| Old Location | New Location |
|-------------|-------------|
| `main_agent.py` | Split into `src/bookkeeper/api/app.py`, `api/routes.py`, `api/models.py`, `agents/orchestrator.py` |
| `agents/*.py` | `src/bookkeeper/agents/*.py` |
| `utils/knowledge_base.py` | `src/bookkeeper/knowledge_base/manager.py` |
| `utils/kb_config.yaml` | `src/bookkeeper/knowledge_base/config.yaml` |
| `test_bedrock.py` | `tests/test_bedrock.py` |
| `invoke_agent.py` | `scripts/invoke_agent.py` |
| `deploy_agent.py` | `scripts/deploy_agent.py` |

### Import Changes

**Before:**
```python
from agents import query_github_agent
from agents.config import bedrock_model
```

**After:**
```python
from bookkeeper.agents import query_github_agent
from bookkeeper.core.config import bedrock_model
```

### Running the Application

**Before:**
```bash
uv run uvicorn main_agent:app --host 0.0.0.0 --port 8080
```

**After:**
```bash
uv run uvicorn bookkeeper.api.app:app --host 0.0.0.0 --port 8080
```

### Docker

The Dockerfile has been updated to:
- Copy `src/` directory instead of individual files
- Use new module path: `bookkeeper.api.app:app`

### Knowledge Base Management

**Before:**
```bash
python utils/knowledge_base.py --mode create
```

**After:**
```bash
uv run python -m bookkeeper.knowledge_base.manager --mode create
```

## Benefits

1. **Proper Packaging**: Follows Python src-layout standard
2. **Clear Separation**: API, agents, core, and KB logic are separated
3. **Better Testing**: Dedicated test directory with fixtures
4. **Cleaner Root**: Configuration files only at root level
5. **Scalability**: Easy to add new modules and components
6. **Professional Structure**: Standard layout for Python projects

## Breaking Changes

If you have existing scripts or deployment configurations that reference the old structure, you'll need to update:

1. Import paths (see Import Changes above)
2. Docker image references
3. Any scripts that call `main_agent.py` directly
4. Environment setup scripts

## Verification

To verify everything works:

```bash
# Install dependencies
uv sync

# Run the application
uv run uvicorn bookkeeper.api.app:app --host 0.0.0.0 --port 8080

# Or with Docker
make build
make run
```

## Questions?

Refer to the updated README.md for complete documentation on the new structure.


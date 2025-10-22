"""Shared test fixtures and configuration"""

import pytest


@pytest.fixture
def sample_prompt():
    """Sample user prompt for testing"""
    return "Find projects similar to a React dashboard with authentication"


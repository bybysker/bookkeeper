"""Specialized agents for GitLab, GitHub, and S3 knowledge base"""

from .github import query_github_agent
from .gitlab import query_gitlab_agent
from .s3 import query_s3_agent

__all__ = ["query_github_agent", "query_gitlab_agent", "query_s3_agent"]


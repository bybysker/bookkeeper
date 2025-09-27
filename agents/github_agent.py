import os
from datetime import datetime, timezone
from mcp.client.streamable_http import streamablehttp_client
from strands import Agent
from strands.tools.mcp.mcp_client import MCPClient
from .prompts import GITHUB_AGENT_SYSTEM_PROMPT


def query_github_agent(user_message):
    """Create an agent with GitHub MCP tools and process user message"""
    try:
        github_token = os.getenv("GITHUB_TOKEN")
        if not github_token:
            raise ValueError("GITHUB_TOKEN environment variable is required")

        headers = {
            "Authorization": f"Bearer {github_token}",
            "Content-Type": "application/json"
        }

        github_mcp_client = MCPClient(
            lambda: streamablehttp_client(
                "https://api.githubcopilot.com/mcp/",
                headers=headers
            )
        )

        with github_mcp_client:
            github_tools = github_mcp_client.list_tools_sync()
            github_agent = Agent(
                tools=github_tools,
                system_prompt=GITHUB_AGENT_SYSTEM_PROMPT,
                trace_attributes={
                    "session.id": "github-agent-{}".format(datetime.now(timezone.utc).date()),
                    "langfuse.tags": ["github-agent"]
                }
            )
            return github_agent(user_message)
    except Exception as e:
        return f"Error running GitHub agent: {str(e)}"

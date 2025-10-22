import os
from datetime import datetime, timezone
from mcp.client.streamable_http import streamablehttp_client
from strands import Agent
from strands.tools.mcp.mcp_client import MCPClient
from mcp import stdio_client, StdioServerParameters
import dotenv
from .prompts import GITLAB_AGENT_SYSTEM_PROMPT

dotenv.load_dotenv()


def query_gitlab_agent(user_message):
    """Create an agent with Gitlab MCP tools and process user message"""
    try:
        gitlab_token = os.getenv("GITLAB_PERSONAL_ACCESS_TOKEN")
        if not gitlab_token:
            raise ValueError("GITLAB_PERSONAL_ACCESS_TOKEN environment variable is required")
            
        gitlab_mcp_client = MCPClient(lambda: stdio_client(
            StdioServerParameters(
                command="docker", 
                args=[
                    "run",
                    "-i",
                    "--rm",
                    "-e",
                    "GITLAB_API_URL",
                    "-e",
                    "GITLAB_PERSONAL_ACCESS_TOKEN",
                    "mcp/gitlab"
                ]
                ,env={
                    "GITLAB_API_URL": "https://gitlab.revolve.team/api/v4",
                    "GITLAB_PERSONAL_ACCESS_TOKEN": os.getenv("GITLAB_PERSONAL_ACCESS_TOKEN")
                }
            )
        ))

        
        with gitlab_mcp_client:
            gitlab_tools = gitlab_mcp_client.list_tools_sync()
            gitlab_agent = Agent(
                tools=gitlab_tools,
                system_prompt=GITLAB_AGENT_SYSTEM_PROMPT,
                trace_attributes={
                    "session.id": "gitlab-agent-{}".format(datetime.now(timezone.utc).date()),
                    "langfuse.tags": ["gitlab-agent"]
                }
            )
            return gitlab_agent(user_message)
    except Exception as e:
        return f"Error running GitLab agent: {str(e)}"


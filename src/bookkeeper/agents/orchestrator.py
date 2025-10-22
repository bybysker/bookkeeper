from datetime import datetime, timezone
from strands import Agent, tool
from strands.tools.executors import ConcurrentToolExecutor
from strands.models import BedrockModel
from .prompts import ORCHESTRATOR_SYSTEM_PROMPT
from .github import query_github_agent
from .gitlab import query_gitlab_agent
from .s3 import query_s3_agent
from typing import List, Optional


class BookkeeperOrchestrator:
    def __init__(
        self,
        bedrock_model_id: str = "us.anthropic.claude-sonnet-4-20250514-v1:0",
        region_name: str = "us-east-1",
        system_prompt: Optional[str] = None,
        tools: Optional[List[callable]] = None,
    ):
        self.model_id = bedrock_model_id
        self.model = BedrockModel(
            model_id=self.model_id,
            region_name=region_name
        )
        
        self.system_prompt = system_prompt if system_prompt else ORCHESTRATOR_SYSTEM_PROMPT
        
        # Define internal assistant tools
        @tool
        def gitlab_assistant(query: str) -> str:
            """
            Handle GitLab-related queries like repository management, issues, merge requests.
            
            Args:
                query: A GitLab-related question or task
                
            Returns:
                Response from GitLab operations
            """
            try:
                result = query_gitlab_agent(query)
                return str(result)
            except Exception as e:
                return f"Error in GitLab assistant: {str(e)}"

        @tool
        def github_assistant(query: str) -> str:
            """
            Handle GitHub-related queries like repository management, issues, pull requests.
            
            Args:
                query: A GitHub-related question or task
                
            Returns:
                Response from GitHub operations
            """
            try:
                result = query_github_agent(query)
                return str(result)
            except Exception as e:
                return f"Error in GitHub assistant: {str(e)}"

        @tool
        def documentation_assistant(query: str) -> str:
            """
            Search and retrieve technical documentation from knowledge base.
            
            Args:
                query: A question about technical documentation or support materials
                
            Returns:
                Relevant documentation content
            """
            try:
                result = query_s3_agent(query)
                return str(result)
            except Exception as e:
                return f"Error in documentation assistant: {str(e)}"
        
        # Combine internal tools with any additional tools provided
        self.tools = [gitlab_assistant, github_assistant, documentation_assistant]
        if tools:
            self.tools.extend(tools)
        
        # Initialize the agent
        self.agent = Agent(
            model=self.model,
            system_prompt=self.system_prompt,
            tool_executor=ConcurrentToolExecutor(),
            tools=self.tools,
            trace_attributes={
                "session.id": "orchestrator-{}".format(datetime.now(timezone.utc).date()),
                "langfuse.tags": ["orchestrator"]
            }
        )
    
    def invoke(self, user_query: str) -> str:
        """
        Process a user query and return the response.
        
        Args:
            user_query: The user's question or request
            
        Returns:
            The agent's response as a string
        """
        try:
            response = str(self.agent(user_query))
        except Exception as e:
            return f"Error invoking agent: {e}"
        return response
    
    async def stream(self, user_query: str):
        """
        Process a user query and stream the response.
        
        Args:
            user_query: The user's question or request
            
        Yields:
            Response chunks as they are generated
        """
        try:
            async for event in self.agent.stream_async(user_query):
                if "data" in event:
                    yield event["data"]
        except Exception as e:
            yield f"We are unable to process your request at the moment. Error: {e}"


from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
from datetime import datetime, timezone
from strands import Agent, tool
from agents import query_gitlab_agent, query_github_agent, query_s3_agent
from agents.config import bedrock_model
from strands.tools.executors import ConcurrentToolExecutor


app = FastAPI(title="Strands Agent Server", version="1.0.0")

# Create specialized agent tools
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

# Orchestrator system prompt
ORCHESTRATOR_PROMPT = """
You are an assistant that routes queries to specialized agents:
- For GitLab tasks (repos, issues, merge requests) → Use gitlab_assistant
- For GitHub tasks (repos, issues, pull requests) → Use github_assistant  
- For technical documentation and support questions → Use documentation_assistant
- For simple questions not requiring specialized knowledge → Answer directly

Always select the most appropriate tool based on the user's query.
"""

# Create orchestrator agent
orchestrator = Agent(
    model=bedrock_model,
    system_prompt=ORCHESTRATOR_PROMPT,
    tool_executor=ConcurrentToolExecutor(), 
    tools=[gitlab_assistant, github_assistant, documentation_assistant],
    trace_attributes={
        "session.id": "orchestrator-{}".format(datetime.now(timezone.utc).date()),
        "langfuse.tags": ["orchestrator"]
    }
)

class InvocationRequest(BaseModel):
    input: Dict[str, Any]

class InvocationResponse(BaseModel):
    output: Dict[str, Any]

@app.post("/invocations", response_model=InvocationResponse)
async def invoke_agent(request: InvocationRequest):
    try:
        user_message = request.input.get("prompt", "")
        if not user_message:
            raise HTTPException(
                status_code=400,
                detail="No prompt found in input. Please provide a 'prompt' key in the input."
            )

        # Use orchestrator to route to appropriate agent
        result = orchestrator(user_message)
        response = {
            "message": result.message,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "model": "strands-orchestrator",
        }

        return InvocationResponse(output=response)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agent processing failed: {str(e)}")

@app.get("/ping")
async def ping():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main_agent:app", host="0.0.0.0", port=8080)
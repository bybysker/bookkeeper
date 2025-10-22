from fastapi import HTTPException
from datetime import datetime, timezone
from .models import InvocationRequest, InvocationResponse
from ..agents.orchestrator import BookkeeperOrchestrator

# Initialize orchestrator instance
orchestrator = BookkeeperOrchestrator()


async def invoke_agent(request: InvocationRequest):
    """Route user prompts to the orchestrator agent"""
    try:
        user_message = request.input.get("prompt", "")
        if not user_message:
            raise HTTPException(
                status_code=400,
                detail="No prompt found in input. Please provide a 'prompt' key in the input."
            )

        # Use orchestrator to route to appropriate agent
        result = orchestrator.invoke(user_message)
        response = {
            "message": result,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "model": "strands-orchestrator",
        }

        return InvocationResponse(output=response)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agent processing failed: {str(e)}")


async def ping():
    """Health check endpoint"""
    return {"status": "healthy"}


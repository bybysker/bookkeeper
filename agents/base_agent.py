from strands import Agent

strands_agent = Agent(
    tools=[],
    trace_attributes={
        "session.id": "abc-134",
        "user.id": "user-email-example@domain.com",
        "langfuse.tags": [
            "Agent-SDK-Example"
        ]
    }
)

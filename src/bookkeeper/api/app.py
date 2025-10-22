from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .models import InvocationResponse
from . import routes

app = FastAPI(title="Strands Agent Server", version="1.0.0")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/invocations", response_model=InvocationResponse)
async def invoke_agent_endpoint(request: routes.InvocationRequest):
    return await routes.invoke_agent(request)


@app.get("/ping")
async def ping_endpoint():
    return await routes.ping()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("bookkeeper.api.app:app", host="0.0.0.0", port=8080)


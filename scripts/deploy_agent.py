import os
import boto3
from dotenv import load_dotenv

load_dotenv()

# Get project/account ID and region from environment variables
PROJECT_ID = os.environ.get('PROJECT_ID')
REGION = os.environ.get('REGION')

if not PROJECT_ID:
    raise EnvironmentError("Environment variable PROJECT_ID is not set.")
if not REGION:
    raise EnvironmentError("Environment variable REGION is not set.")

container_uri = f"{PROJECT_ID}.dkr.ecr.{REGION}.amazonaws.com/my-strands-agent:latest"
role_arn = f"arn:aws:iam::{PROJECT_ID}:role/AgentRuntimeRole"

client = boto3.client('bedrock-agentcore-control', region_name=REGION)

response = client.create_agent_runtime(
    agentRuntimeName='strands_agent',
    agentRuntimeArtifact={
        'containerConfiguration': {
            'containerUri': container_uri
        }
    },
    networkConfiguration={"networkMode": "PUBLIC"},
    roleArn=role_arn
)

print(f"Agent Runtime created successfully!")
print(f"Agent Runtime ARN: {response['agentRuntimeArn']}")
print(f"Status: {response['status']}")
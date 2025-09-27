import boto3

client = boto3.client('bedrock-agentcore-control')

response = client.create_agent_runtime(
    agentRuntimeName='strands_agent',
    agentRuntimeArtifact={
        'containerConfiguration': {
            'containerUri': '286830035804.dkr.ecr.us-east-1.amazonaws.com/my-strands-agent:latest'
        }
    },
    networkConfiguration={"networkMode": "PUBLIC"},
    roleArn='arn:aws:iam::286830035804:role/AgentRuntimeRole'
)

print(f"Agent Runtime created successfully!")
print(f"Agent Runtime ARN: {response['agentRuntimeArn']}")
print(f"Status: {response['status']}")
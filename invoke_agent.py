import boto3
import json

agent_core_client = boto3.client('bedrock-agentcore', region_name='us-east-1')
payload = json.dumps({
    "input": {"prompt": "errors fixed. what AI project did devoteam built from s3 docs ?"}
})

response = agent_core_client.invoke_agent_runtime(
    agentRuntimeArn='arn:aws:bedrock-agentcore:us-east-1:286830035804:runtime/hosted_agent_sm37z-yDVwm7CIQe',
    runtimeSessionId='dfmeoagmreaklgmrkleafremoigrmtesogmtrskhmtkrlshmt',  # Must be 33+ chars
    payload=payload,
    qualifier="DEFAULT"
)

response_body = response['response'].read()
response_data = json.loads(response_body)
print("Agent Response:", response_data)
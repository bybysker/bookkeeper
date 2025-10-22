from strands import Agent, tool
import boto3
from strands_tools import retrieve
from datetime import datetime, timezone
import os
import dotenv
from ..core.config import bedrock_model
from .prompts import S3_AGENT_SYSTEM_PROMPT

dotenv.load_dotenv()


@tool
def get_s3_files(issue_description: str) -> str:
	try:
		# Get KB ID from parameter store
		region = 'us-east-1'  # Use the same region as bedrock_model
		ssm = boto3.client('ssm', region_name=region)
		account_id = boto3.client('sts').get_caller_identity()['Account']

		kb_id = ssm.get_parameter(Name=f"/{account_id}-{region}/kb/knowledge-base-id")['Parameter']['Value']
		print(f"Successfully retrieved KB ID: {kb_id}")

		# Use strands retrieve tool
		tool_use = {
			"toolUseId": "s3_query",
			"input": {
				"text": issue_description,
				"knowledgeBaseId": kb_id,
				"region": region,
				"numberOfResults": 3,
				"score": 0.4
			}
		}

		result = retrieve.retrieve(tool_use)
		print(result)
		if result["status"] == "success":
			return result["content"][0]["text"]
		else:
			return f"Unable to access technical support documentation. Error: {result['content'][0]['text']}"

	except Exception as e:
		print(f"Detailed error in get_s3_files: {str(e)}")
		return f"Unable to access technical support documentation. Error: {str(e)}"

def query_s3_agent(user_message):
	try:
		s3_agent = Agent(
			model=bedrock_model,
			system_prompt=S3_AGENT_SYSTEM_PROMPT,
			tools=[get_s3_files],
			trace_attributes={
				"session.id": "s3-agent-{}".format(datetime.now(timezone.utc).date()),
				"langfuse.tags": ["s3-agent"]
			}
		)

		return s3_agent(user_message)
	except Exception as e:
		return f"Error running S3 agent: {str(e)}"


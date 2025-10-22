#!/usr/bin/env python3
"""
Simple test script to verify Bedrock calls and LiteLLM with Bedrock integration.
"""

import os
from litellm import completion
from strands.models import BedrockModel
from strands.models.litellm import LiteLLMModel
from strands import Agent
import dotenv
dotenv.load_dotenv()

# AWS credentials (using the same ones from agent.py)
os.environ["AWS_ACCESS_KEY_ID"] = os.getenv("AWS_ACCESS_KEY_ID")
os.environ["AWS_SECRET_ACCESS_KEY"] = os.getenv("AWS_SECRET_ACCESS_KEY")
os.environ["AWS_REGION_NAME"] = os.getenv("AWS_REGION_NAME")
os.environ["AWS_SESSION_TOKEN"] = os.getenv("AWS_SESSION_TOKEN")

def test_litellm_bedrock():
    """Test LiteLLM with Bedrock directly."""
    print("Testing LiteLLM with Bedrock...")
    try:
        response = completion(
            model="bedrock/anthropic.claude-3-sonnet-20240229-v1:0",
            messages=[{"content": "Say 'Hello from Bedrock via LiteLLM!'", "role": "user"}]
        )
        print(f"✅ LiteLLM Bedrock Success: {response.choices[0].message.content}")
        return True
    except Exception as e:
        print(f"❌ LiteLLM Bedrock Failed: {e}")
        return False

def test_strands_bedrock():
    """Test Strands BedrockModel."""
    print("\nTesting Strands BedrockModel...")
    try:
        model = BedrockModel(model_id="anthropic.claude-3-5-sonnet-20240620-v1:0")
        agent = Agent(model=model)
        response = agent("Say 'Hello from Bedrock via Strands!'")
        print(f"✅ Strands Bedrock Success: {response.message}")
        return True
    except Exception as e:
        print(f"❌ Strands Bedrock Failed: {e}")
        return False

def test_strands_litellm():
    """Test Strands LiteLLMModel with proxy."""
    print("\nTesting Strands LiteLLMModel...")
    try:
        model = LiteLLMModel(
            client_args={
                "api_key": "sk-gyPffJl3XA5Ci9z9zCk0A",
                "api_base": "https://d2if7psjphwjb4.cloudfront.net/",
                "use_litellm_proxy": True
            },
            model_id="eu.anthropic.claude-3-5-sonnet-20240620-v1:0"
        )
        agent = Agent(model=model)
        response = agent("Say 'Hello from LiteLLM proxy via Strands!'")
        print(f"✅ Strands LiteLLM Success: {response.message}")
        return True
    except Exception as e:
        print(f"❌ Strands LiteLLM Failed: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Testing Bedrock and LiteLLM integrations...\n")
    
    results = []
    results.append(test_litellm_bedrock())
    results.append(test_strands_bedrock())
    results.append(test_strands_litellm())
    
    print(f"\n📊 Results: {sum(results)}/{len(results)} tests passed")
    
    if all(results):
        print("🎉 All tests passed!")
    else:
        print("⚠️  Some tests failed - check the output above")

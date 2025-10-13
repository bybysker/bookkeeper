import os
import base64
import dotenv
from strands.telemetry import StrandsTelemetry
from strands.models.litellm import LiteLLMModel
from strands.models import BedrockModel
import boto3

dotenv.load_dotenv()

# Langfuse Setup
LANGFUSE_AUTH = base64.b64encode(
    f"{os.environ.get('LANGFUSE_PUBLIC_KEY')}:{os.environ.get('LANGFUSE_SECRET_KEY')}".encode()
).decode()

os.environ["OTEL_EXPORTER_OTLP_ENDPOINT"] = os.environ.get("LANGFUSE_HOST") + "/api/public/otel"
os.environ["OTEL_EXPORTER_OTLP_HEADERS"] = f"Authorization=Basic {LANGFUSE_AUTH}"

# Telemetry
strands_telemetry = StrandsTelemetry().setup_otlp_exporter()

# Models
litellm_bedrock_model = LiteLLMModel(
    client_args={
        "api_key": "sk-IBxM7eyXftfGqZyuMREEaw",
        "api_base": "https://d3mgibprdimq9c.cloudfront.net/",
        "use_litellm_proxy": True
    },
    model_id="eu.anthropic.claude-3-5-sonnet-20240620-v1:0"
)

bedrock_model = BedrockModel(
    model_id="us.anthropic.claude-sonnet-4-20250514-v1:0",
    region_name='us-east-1'
)


# Bookkeeper

An intelligent orchestrator system that helps find similar projects and relevant documentation across multiple platforms using specialized AI agents.

## Overview

Bookkeeper is a FastAPI-based service that routes queries to specialized agents for finding similar projects and technical documentation. It integrates with GitLab, GitHub, and AWS S3 knowledge bases to provide comprehensive project discovery and documentation search capabilities.

## Architecture

The system uses an orchestrator pattern with three specialized agents:

- **GitLab Agent**: Analyzes GitLab repositories for similar projects
- **GitHub Agent**: Searches GitHub repositories for comparable work  
- **S3 Agent**: Retrieves relevant technical documentation from AWS knowledge bases

## Features

- 🔍 **Multi-platform Search**: Search across GitLab, GitHub, and S3 documentation
- 🧠 **AI-Powered Matching**: Uses Claude Sonnet 4 for intelligent project similarity analysis
- 📊 **Structured Results**: Returns similarity scores and detailed project metadata
- 🔄 **Concurrent Processing**: Parallel agent execution for faster results
- 📈 **Observability**: Built-in tracing with Langfuse integration

## Quick Start

### Prerequisites

- Python 3.11+
- Docker (for GitLab MCP client)
- AWS credentials configured
- Terraform (for infrastructure deployment)
- Required environment variables (see Configuration)

### Installation

```bash
# Install dependencies
uv sync

# Run the service locally
uv run uvicorn main_agent:app --host 0.0.0.0 --port 8080
```

### Docker Deployment

Using Makefile (recommended):
```bash
# Build and run
make build
make run

# View logs
make logs

# Rebuild (clean + build + run)
make rebuild
```

Or manually:
```bash
docker build -t bookkeeper .
docker run -d --name bookkeeper-container --env-file .env -p 8080:8080 bookkeeper
```

## Configuration

Set the following environment variables:

```bash
# GitLab Access
GITLAB_PERSONAL_ACCESS_TOKEN=your_gitlab_token
GITLAB_API_URL=https://gitlab.revolve.team/api/v4

# GitHub Access  
GITHUB_TOKEN=your_github_token

# AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_DEFAULT_REGION=us-east-1

# Langfuse Telemetry
LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
LANGFUSE_SECRET_KEY=your_langfuse_secret_key
LANGFUSE_HOST=your_langfuse_host
```

## API Usage

### Main Endpoint

```bash
POST /invocations
```

**Request:**
```json
{
  "input": {
    "prompt": "Find projects similar to a React dashboard with authentication"
  }
}
```

**Response:**
```json
{
  "output": {
    "message": "Found similar projects in GitLab and GitHub...",
    "timestamp": "2024-01-01T12:00:00Z",
    "model": "strands-orchestrator"
  }
}
```

### Health Check

```bash
GET /ping
```

## Knowledge Base Setup

The S3 agent requires an AWS Bedrock Knowledge Base. 

**Recommended:** Use Terraform for infrastructure setup (see Infrastructure Setup section).

**Alternative:** Use the Python utility for manual management:

```bash
# Create knowledge base
python utils/knowledge_base.py --mode create

# Delete knowledge base  
python utils/knowledge_base.py --mode delete
```

Configure knowledge base settings in `utils/kb_config.yaml`.

## Agent Details

### GitLab Agent
- Analyzes repositories, README files, and commit history
- Identifies technical stack and project domains
- Returns similarity scores and contributor information

### GitHub Agent  
- Searches public/private repositories
- Analyzes package files and documentation
- Considers stars/forks as quality indicators

### S3 Agent
- Searches technical documentation using embeddings
- Retrieves project specifications and reports
- Provides relevant document excerpts with scores

## Development

### Project Structure

```
bookkeeper/
├── agents/              # Specialized agent implementations
│   ├── gitlab_agent.py  # GitLab integration
│   ├── github_agent.py  # GitHub integration
│   ├── s3_agent.py      # S3 knowledge base search
│   ├── prompts.py       # Agent system prompts
│   └── config.py        # Model configuration
├── terraform/           # Infrastructure as Code
│   ├── main.tf          # Provider configuration
│   ├── ecr.tf           # ECR repository
│   ├── bedrock.tf       # Bedrock knowledge base
│   ├── opensearch.tf    # OpenSearch Serverless
│   ├── s3.tf            # S3 bucket for data
│   ├── iam.tf           # IAM roles and policies
│   └── variables.tf     # Input variables
├── utils/               # Utility modules
│   ├── knowledge_base.py # KB management
│   └── kb_config.yaml   # KB configuration
├── main_agent.py        # FastAPI orchestrator service
├── deploy.sh            # ECR deployment script
├── Dockerfile           # Container configuration
├── Makefile             # Build automation
└── pyproject.toml       # Dependencies
```

### Key Dependencies

- **FastAPI**: Web framework for API endpoints
- **Strands Agents**: Agent framework with tool execution  
- **LiteLLM**: Model integration layer
- **Langfuse**: Observability and tracing
- **Pydantic**: Data validation and settings management

## Infrastructure Setup

### Terraform Deployment

The project includes Terraform configuration for AWS infrastructure:

```bash
cd terraform

# Initialize Terraform
terraform init

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy infrastructure
terraform plan
terraform apply
```

**Resources created:**
- ECR repository for Docker images
- OpenSearch Serverless collection for vector storage
- S3 bucket for knowledge base data
- IAM roles and policies for Bedrock access
- Bedrock Knowledge Base with Titan embeddings

See [terraform/README.md](terraform/README.md) for detailed configuration options.

## Deployment

### AWS ECR Deployment

After infrastructure is provisioned, deploy the application:

```bash
# Configure variables in deploy.sh
ACCOUNT_ID="your-aws-account-id" ./deploy.sh
```

The script will:
1. Login to ECR
2. Build Docker image for ARM64 architecture
3. Push image to ECR
4. Verify deployment

### Environment Variables

The application uses dotenv for configuration. Create a `.env` file with all required variables.

## Contributing

1. Follow the existing code structure
2. Add appropriate error handling
3. Include tracing attributes for observability
4. Test agent integrations thoroughly

## License

This project is proprietary software. All rights reserved.


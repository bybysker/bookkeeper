# AWS Infrastructure Terraform Configuration

This Terraform configuration creates and manages AWS infrastructure for the bookkeeper project, including ECR repository and Bedrock Knowledge Base.

## Files

- `main.tf` - Provider configuration
- `ecr.tf` - ECR repository and lifecycle policy
- `opensearch.tf` - OpenSearch Serverless collection and security policies
- `s3.tf` - S3 bucket for knowledge base data source
- `iam.tf` - IAM roles and policies for Bedrock access
- `bedrock.tf` - Bedrock Knowledge Base configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example variables file

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Copy and customize variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars as needed
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Resources Created

### ECR Repository
- ECR repository with image scanning enabled
- Lifecycle policy to manage image retention
- AES256 encryption for images

### Bedrock Knowledge Base
- OpenSearch Serverless vector collection
- S3 bucket for data source with encryption
- IAM roles and policies for secure access
- Bedrock Knowledge Base configured with Titan embeddings

## Integration

- **ECR**: Matches the repository referenced in `../deploy.sh`
- **Knowledge Base**: Compatible with the S3 agent in `../agents/s3_agent.py`
- **Configuration**: Uses values from `../utils/kb_config.yaml`

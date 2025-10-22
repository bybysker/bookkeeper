# Bookkeeper Deployment Guide

This guide explains how to deploy the Bookkeeper infrastructure to AWS.

## Prerequisites

Before deploying, ensure you have:

1. **AWS CLI** configured with appropriate credentials
   ```bash
   aws configure
   ```

2. **Terraform** installed (>= 1.0)
   ```bash
   terraform version
   ```

3. **Docker** installed and running
   ```bash
   docker --version
   ```

4. **Docker Buildx** enabled for multi-platform builds
   ```bash
   docker buildx version
   ```

## Deployment Methods

### Method 1: Automated Full Deployment (Recommended)

Use the provided deployment script for a complete, orchestrated deployment:

```bash
# Make script executable (if not already)
chmod +x deploy-full.sh

# Run full deployment
./deploy-full.sh
```

Or using Make:

```bash
make deploy
```

This script will:
1. Check all prerequisites
2. Initialize Terraform
3. Deploy ECR repositories first
4. Build and push Docker images to ECR
5. Deploy remaining infrastructure (S3, OpenSearch, Bedrock, Agent Runtime)
6. Display deployment outputs

### Method 2: Manual Step-by-Step Deployment

If you prefer manual control:

#### Step 1: Initialize Terraform
```bash
cd terraform
terraform init
```

#### Step 2: Deploy ECR Repositories Only
```bash
# Using Makefile
make deploy-ecr

# Or directly with Terraform
terraform apply \
  -target=aws_ecr_repository.my_strands_agent \
  -target=aws_ecr_lifecycle_policy.my_strands_agent_policy \
  -target=random_id.suffix \
  -target=awscc_ecr_repository.agent_runtime \
  -auto-approve
```

#### Step 3: Get ECR URIs
```bash
# Get strands agent ECR URI
STRANDS_ECR_URI=$(terraform output -raw ecr_repository_url)

# Get agent runtime ECR URI
AGENT_RUNTIME_ECR_URI=$(terraform output -raw agent_runtime_ecr_repository_uri)

echo "Strands Agent ECR: $STRANDS_ECR_URI"
echo "Agent Runtime ECR: $AGENT_RUNTIME_ECR_URI"
```

#### Step 4: Login to ECR
```bash
REGION=us-east-1  # or your preferred region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

#### Step 5: Build and Push Docker Images
```bash
cd ..  # Back to project root

# Build and push strands agent image
docker buildx build --platform linux/arm64 -t $STRANDS_ECR_URI:latest --push .

# Tag and push agent runtime image
docker tag $STRANDS_ECR_URI:latest $AGENT_RUNTIME_ECR_URI:latest
docker push $AGENT_RUNTIME_ECR_URI:latest
```

#### Step 6: Deploy Remaining Infrastructure
```bash
cd terraform

# Using Makefile
make deploy-infra

# Or directly with Terraform
terraform apply -auto-approve
```

## Configuration

### Terraform Variables

Edit `terraform/terraform.tfvars` to customize your deployment:

```hcl
aws_region              = "us-east-1"
repository_name         = "strands-agent"
environment             = "production"
knowledge_base_name     = "customer-support"
opensearch_collection_name = "kb-collection"
s3_bucket_name          = "kb-data-source"
gitlab_api_url          = "https://gitlab.revolve.team/api/v4"
langfuse_host           = "https://cloud.langfuse.com"
```

### Environment Variables

The deployment script respects the following environment variables:

- `AWS_REGION`: AWS region to deploy to (default: us-east-1)
- Standard AWS CLI environment variables (AWS_PROFILE, AWS_ACCESS_KEY_ID, etc.)

### Secrets Management

The deployment creates AWS Secrets Manager secrets for sensitive credentials. After deployment, you **must** update these secrets with actual values:

#### Update Secrets Using Helper Script (Recommended)

The easiest way to update secrets is using the provided helper script:

```bash
cd terraform
./update-secrets.sh
```

This interactive script will prompt you for each secret value and update them securely.

#### Update Secrets Using AWS CLI

```bash
# Get secret names from Terraform outputs
terraform output gitlab_token_secret_name
terraform output langfuse_public_key_secret_name
terraform output langfuse_secret_key_secret_name

# Update GitLab Personal Access Token
aws secretsmanager update-secret \
  --secret-id $(terraform output -raw gitlab_token_secret_name) \
  --secret-string "your-actual-gitlab-token"

# Update Langfuse Public Key
aws secretsmanager update-secret \
  --secret-id $(terraform output -raw langfuse_public_key_secret_name) \
  --secret-string "your-actual-langfuse-public-key"

# Update Langfuse Secret Key
aws secretsmanager update-secret \
  --secret-id $(terraform output -raw langfuse_secret_key_secret_name) \
  --secret-string "your-actual-langfuse-secret-key"
```

#### Update Secrets Using AWS Console

1. Navigate to AWS Secrets Manager in the AWS Console
2. Find the secrets with names starting with `bookkeeper/`
3. Click on each secret and select "Retrieve secret value"
4. Click "Edit" and replace the placeholder with your actual value
5. Save changes

#### Security Best Practices

- **Never commit secrets** to version control
- Use **IAM policies** to restrict access to secrets
- Enable **CloudTrail logging** to audit secret access
- Rotate secrets regularly using AWS Secrets Manager rotation
- Use **least privilege** principles when granting access
- Consider using **VPC endpoints** for Secrets Manager in production

## Deployed Resources

The deployment creates:

### ECR Repositories
- **strands-agent**: Standard ECR repository for the main application
- **bedrock/agent-runtime-{suffix}**: AWSCC ECR repository for Bedrock Agent Runtime

### IAM Resources
- Bedrock Knowledge Base role and policies
- Agent Runtime role and policies

### S3
- Knowledge base data bucket with versioning and encryption

### OpenSearch Serverless
- Collection for vector search
- Index for knowledge base embeddings

### Bedrock
- Knowledge Base with Titan embeddings
- S3 data source integration

### Agent Core Runtime
- Bedrock Agent Core Runtime
- Container configuration pointing to ECR
- Environment variables for knowledge base integration

### Secrets Manager
- GitLab Personal Access Token secret
- Langfuse Public Key secret
- Langfuse Secret Key secret
- All secrets have 7-day recovery window for safe deletion

## Outputs

After deployment, Terraform provides the following outputs:

```bash
# View all outputs
terraform output

# View specific outputs
terraform output ecr_repository_url
terraform output agent_runtime_id
terraform output knowledge_base_id

# View secret information
terraform output gitlab_token_secret_name
terraform output langfuse_public_key_secret_arn
terraform output langfuse_secret_key_secret_arn
```

Key outputs include:
- **ECR repository URIs** for container images
- **Agent Runtime ID and ARN** for the deployed runtime
- **Knowledge Base ID** for querying
- **Secret ARNs and names** for updating credentials

## Troubleshooting

### ECR Login Issues
If ECR login fails:
```bash
# Check AWS credentials
aws sts get-caller-identity

# Try explicit region
aws ecr get-login-password --region us-east-1
```

### Docker Build Issues
If ARM64 build fails:
```bash
# Check buildx
docker buildx ls

# Create new builder if needed
docker buildx create --name mybuilder --use
```

### Terraform State Issues
If state is corrupted:
```bash
# Backup state
cp terraform.tfstate terraform.tfstate.backup

# Refresh state
terraform refresh
```

### Agent Runtime Name Validation Error
The agent runtime name must match pattern `[a-zA-Z][a-zA-Z0-9_]{0,47}`:
- ✅ Valid: `bookkeeper_agent_runtime_abc123`
- ❌ Invalid: `bookkeeper-agent-runtime-abc123` (hyphens not allowed)

## Cleanup

To destroy all resources:

```bash
cd terraform

# Using Makefile
make tf-destroy

# Or directly
terraform destroy
```

**Warning**: This will delete all resources including S3 buckets and data!

## Next Steps

After deployment:

1. **Update secrets with actual values** (CRITICAL - required for runtime to work):
   ```bash
   aws secretsmanager update-secret \
     --secret-id $(terraform output -raw gitlab_token_secret_name) \
     --secret-string "your-gitlab-token"
   
   aws secretsmanager update-secret \
     --secret-id $(terraform output -raw langfuse_public_key_secret_name) \
     --secret-string "your-langfuse-public-key"
   
   aws secretsmanager update-secret \
     --secret-id $(terraform output -raw langfuse_secret_key_secret_name) \
     --secret-string "your-langfuse-secret-key"
   ```

2. Upload documents to the S3 knowledge base bucket

3. Sync the Bedrock knowledge base data source

4. Test the agent runtime with sample queries

5. Configure your application to use the deployed endpoints

## Support

For issues or questions:
- Check Terraform state: `terraform show`
- View AWS CloudWatch logs for agent runtime
- Review ECR images: `aws ecr describe-images --repository-name <name>`


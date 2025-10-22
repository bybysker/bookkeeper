# Secrets Management for Bookkeeper

This document explains how secrets are managed in the Bookkeeper infrastructure.

## Overview

Sensitive credentials (API tokens, keys) are stored in **AWS Secrets Manager** for security. The Agent Runtime retrieves these secrets automatically at startup using IAM permissions.

## Secrets Created

The following secrets are created during Terraform deployment:

| Secret Name Pattern | Environment Variable | Description |
|-------------------|---------------------|-------------|
| `bookkeeper/gitlab-personal-access-token-{suffix}` | `GITLAB_PERSONAL_ACCESS_TOKEN` | GitLab API access token |
| `bookkeeper/langfuse-public-key-{suffix}` | `LANGFUSE_PUBLIC_KEY` | Langfuse observability public key |
| `bookkeeper/langfuse-secret-key-{suffix}` | `LANGFUSE_SECRET_KEY` | Langfuse observability secret key |

## Initial Setup

After deploying infrastructure, all secrets contain placeholder values (`PLACEHOLDER_UPDATE_AFTER_DEPLOYMENT`). You **must** update them with actual values.

### Method 1: Interactive Script (Recommended)

```bash
cd terraform
./update-secrets.sh
```

This script will:
- Automatically detect secret names from Terraform outputs
- Prompt you for each secret value (hidden input)
- Update all secrets securely
- Confirm successful updates

### Method 2: AWS CLI

```bash
# Get secret names
GITLAB_SECRET=$(terraform output -raw gitlab_token_secret_name)
LANGFUSE_PUBLIC=$(terraform output -raw langfuse_public_key_secret_name)
LANGFUSE_SECRET=$(terraform output -raw langfuse_secret_key_secret_name)

# Update secrets
aws secretsmanager update-secret \
  --secret-id "${GITLAB_SECRET}" \
  --secret-string "glpat-xxxxxxxxxxxxxxxxxxxx"

aws secretsmanager update-secret \
  --secret-id "${LANGFUSE_PUBLIC}" \
  --secret-string "pk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

aws secretsmanager update-secret \
  --secret-id "${LANGFUSE_SECRET}" \
  --secret-string "sk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Method 3: AWS Console

1. Open [AWS Secrets Manager Console](https://console.aws.amazon.com/secretsmanager/)
2. Search for secrets starting with `bookkeeper/`
3. Click on each secret
4. Click "Retrieve secret value"
5. Click "Edit"
6. Replace the placeholder with your actual value
7. Click "Save"

## Verifying Secrets

### Check Secret Exists

```bash
aws secretsmanager describe-secret \
  --secret-id $(terraform output -raw gitlab_token_secret_name)
```

### Retrieve Secret Value

```bash
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw gitlab_token_secret_name) \
  --query SecretString \
  --output text
```

## How Secrets Are Used

The Agent Runtime automatically fetches secrets at startup:

1. **IAM Role**: The runtime has permissions to read secrets under `bookkeeper/*`
2. **Environment Variables**: Secret ARNs are passed as environment variables
3. **Runtime Fetch**: The runtime uses AWS SDK to fetch actual values
4. **In-Memory**: Secrets are kept in memory and never written to disk

## Security Best Practices

### Access Control

- ✅ Secrets are only accessible by the Agent Runtime IAM role
- ✅ Use least privilege - only grant necessary permissions
- ✅ Enable CloudTrail to audit secret access

### Rotation

Rotate secrets regularly:

```bash
# Generate new token in GitLab/Langfuse
# Update secret with new value
aws secretsmanager update-secret \
  --secret-id <secret-name> \
  --secret-string "new-token-value"

# No need to restart runtime - it fetches on each use
```

### Secret Deletion

Secrets have a **7-day recovery window**:

```bash
# Delete secret (can be recovered within 7 days)
aws secretsmanager delete-secret \
  --secret-id <secret-name>

# Restore deleted secret
aws secretsmanager restore-secret \
  --secret-id <secret-name>

# Force delete immediately (cannot be recovered)
aws secretsmanager delete-secret \
  --secret-id <secret-name> \
  --force-delete-without-recovery
```

### Never Store in Code

❌ **DON'T** store secrets in:
- Source code
- Git repositories
- Configuration files
- Environment variables in Dockerfile
- Terraform tfvars files

✅ **DO** store secrets in:
- AWS Secrets Manager
- AWS Systems Manager Parameter Store (encrypted)
- HashiCorp Vault
- Other secure secret management systems

## Troubleshooting

### Secret Not Found

If runtime reports "secret not found":

```bash
# Check secret exists
aws secretsmanager list-secrets --filters Key=name,Values=bookkeeper/

# Verify IAM permissions
aws iam get-role-policy \
  --role-name <agent-runtime-role-name> \
  --policy-name bedrock-agent-runtime-policy
```

### Access Denied

If runtime reports "access denied":

1. Check IAM role has `secretsmanager:GetSecretValue` permission
2. Verify secret ARN matches pattern in IAM policy
3. Ensure runtime is using correct IAM role

### Placeholder Values Still Present

If you see `PLACEHOLDER_UPDATE_AFTER_DEPLOYMENT` in logs:

```bash
# Update the secret
aws secretsmanager update-secret \
  --secret-id <secret-name> \
  --secret-string "actual-value"

# Restart or redeploy runtime to pick up changes
```

## Cost

AWS Secrets Manager pricing (as of 2025):
- **$0.40** per secret per month
- **$0.05** per 10,000 API calls

For 3 secrets with typical usage: ~**$1.50/month**

## Additional Resources

- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)
- [Best Practices for AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [IAM Permissions for Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access.html)


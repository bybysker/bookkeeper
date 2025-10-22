#!/bin/bash

# Helper script to update AWS Secrets Manager secrets for Bookkeeper
# This script prompts for secret values and updates them in AWS Secrets Manager

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo ""
log_info "Bookkeeper Secrets Update Script"
echo ""

# Check if terraform outputs are available
if ! terraform output gitlab_token_secret_name &> /dev/null; then
    log_error "Cannot find Terraform outputs. Make sure you're in the terraform directory and have deployed the infrastructure."
    exit 1
fi

# Get secret names from Terraform outputs
GITLAB_SECRET_NAME=$(terraform output -raw gitlab_token_secret_name)
LANGFUSE_PUBLIC_SECRET_NAME=$(terraform output -raw langfuse_public_key_secret_name)
LANGFUSE_SECRET_SECRET_NAME=$(terraform output -raw langfuse_secret_key_secret_name)

log_info "Found secrets:"
echo "  - GitLab Token: ${GITLAB_SECRET_NAME}"
echo "  - Langfuse Public Key: ${LANGFUSE_PUBLIC_SECRET_NAME}"
echo "  - Langfuse Secret Key: ${LANGFUSE_SECRET_SECRET_NAME}"
echo ""

# Update GitLab Token
log_info "Update GitLab Personal Access Token"
echo -n "Enter GitLab Personal Access Token: "
read -s GITLAB_TOKEN
echo ""

if [ -z "$GITLAB_TOKEN" ]; then
    log_warning "Skipping GitLab token (empty value provided)"
else
    aws secretsmanager update-secret \
        --secret-id "${GITLAB_SECRET_NAME}" \
        --secret-string "${GITLAB_TOKEN}" \
        --output text > /dev/null
    log_success "GitLab token updated"
fi
echo ""

# Update Langfuse Public Key
log_info "Update Langfuse Public Key"
echo -n "Enter Langfuse Public Key: "
read -s LANGFUSE_PUBLIC
echo ""

if [ -z "$LANGFUSE_PUBLIC" ]; then
    log_warning "Skipping Langfuse public key (empty value provided)"
else
    aws secretsmanager update-secret \
        --secret-id "${LANGFUSE_PUBLIC_SECRET_NAME}" \
        --secret-string "${LANGFUSE_PUBLIC}" \
        --output text > /dev/null
    log_success "Langfuse public key updated"
fi
echo ""

# Update Langfuse Secret Key
log_info "Update Langfuse Secret Key"
echo -n "Enter Langfuse Secret Key: "
read -s LANGFUSE_SECRET
echo ""

if [ -z "$LANGFUSE_SECRET" ]; then
    log_warning "Skipping Langfuse secret key (empty value provided)"
else
    aws secretsmanager update-secret \
        --secret-id "${LANGFUSE_SECRET_SECRET_NAME}" \
        --secret-string "${LANGFUSE_SECRET}" \
        --output text > /dev/null
    log_success "Langfuse secret key updated"
fi
echo ""

log_success "Secret update complete!"
echo ""
log_info "To verify, you can check the secrets in AWS Console or use:"
echo "  aws secretsmanager get-secret-value --secret-id ${GITLAB_SECRET_NAME}"
echo ""


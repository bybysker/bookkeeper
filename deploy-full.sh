#!/bin/bash

# Full Deployment Script for Bookkeeper
# This script:
# 1. Deploys ECR repositories first
# 2. Builds and pushes Docker images
# 3. Deploys remaining infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGION="${AWS_REGION:-us-east-1}"
TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terraform"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions
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

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    log_success "Prerequisites checked. AWS Account: ${ACCOUNT_ID}"
}

init_terraform() {
    log_info "Initializing Terraform..."
    cd "${TERRAFORM_DIR}"
    terraform init
    log_success "Terraform initialized"
}

deploy_ecr() {
    log_info "Deploying ECR repositories only..."
    cd "${TERRAFORM_DIR}"
    
    # Deploy only ECR resources
    terraform apply \
        -target=aws_ecr_repository.my_strands_agent \
        -target=aws_ecr_lifecycle_policy.my_strands_agent_policy \
        -target=random_id.suffix \
        -target=awscc_ecr_repository.agent_runtime \
        -auto-approve
    
    log_success "ECR repositories deployed"
}

get_ecr_uris() {
    log_info "Retrieving ECR repository URIs..."
    cd "${TERRAFORM_DIR}"
    
    # Get standard ECR repository URI
    STRANDS_ECR_URI=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")
    
    # Get agent runtime ECR repository URI
    AGENT_RUNTIME_ECR_URI=$(terraform output -raw agent_runtime_ecr_repository_uri 2>/dev/null || echo "")
    
    if [ -z "$STRANDS_ECR_URI" ] || [ -z "$AGENT_RUNTIME_ECR_URI" ]; then
        log_error "Failed to retrieve ECR URIs from Terraform outputs"
        exit 1
    fi
    
    log_success "ECR URIs retrieved"
    log_info "Strands Agent ECR: ${STRANDS_ECR_URI}"
    log_info "Agent Runtime ECR: ${AGENT_RUNTIME_ECR_URI}"
}

login_to_ecr() {
    log_info "Logging into ECR..."
    aws ecr get-login-password --region ${REGION} | \
        docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
    log_success "Logged into ECR"
}

build_and_push_images() {
    log_info "Building and pushing Docker images..."
    cd "${SCRIPT_DIR}"
    
    # Build and push strands agent image and agent runtime image (multi-tag push)
    log_info "Building and pushing images to both repositories..."
    docker buildx build --platform linux/arm64 \
        -t ${STRANDS_ECR_URI}:latest \
        -t ${AGENT_RUNTIME_ECR_URI}:latest \
        --push .
    
    log_success "Strands Agent image pushed: ${STRANDS_ECR_URI}:latest"
    log_success "Agent Runtime image pushed: ${AGENT_RUNTIME_ECR_URI}:latest"
}

deploy_remaining_infrastructure() {
    log_info "Deploying remaining infrastructure..."
    cd "${TERRAFORM_DIR}"
    
    # Deploy all remaining resources
    terraform apply -auto-approve
    
    log_success "All infrastructure deployed"
}

display_outputs() {
    log_info "Deployment Summary"
    echo ""
    cd "${TERRAFORM_DIR}"
    terraform output
    echo ""
    log_warning "IMPORTANT: You must update the secrets with actual values!"
    echo ""
    log_info "Run the following to update secrets:"
    echo "  cd ${TERRAFORM_DIR} && ./update-secrets.sh"
    echo ""
    log_info "Or update manually using AWS CLI - see terraform/DEPLOYMENT.md for details"
}

main() {
    echo ""
    log_info "🚀 Starting Full Bookkeeper Deployment"
    echo ""
    
    # Step 1: Check prerequisites
    check_prerequisites
    echo ""
    
    # Step 2: Initialize Terraform
    init_terraform
    echo ""
    
    # Step 3: Deploy ECR repositories first
    deploy_ecr
    echo ""
    
    # Step 4: Get ECR URIs
    get_ecr_uris
    echo ""
    
    # Step 5: Login to ECR
    login_to_ecr
    echo ""
    
    # Step 6: Build and push Docker images
    build_and_push_images
    echo ""
    
    # Step 7: Deploy remaining infrastructure
    deploy_remaining_infrastructure
    echo ""
    
    # Step 8: Display outputs
    display_outputs
    echo ""
    
    log_success "🎉 Full deployment complete!"
    echo ""
}

# Run main function
main


#!/bin/bash

# AWS ECR Deployment Script
# Simple script to build and push Docker image to ECR

set -e  # Exit on any error

# Configuration
REPOSITORY_NAME="my-strands-agent"
REGION="us-east-1"
ACCOUNT_ID=""
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${REPOSITORY_NAME}:latest"

echo "🚀 Starting deployment to ECR..."

# Step 1: Create ECR repository (will skip if already exists)
echo "📦 Creating ECR repository..."
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${REGION} 2>/dev/null || echo "Repository already exists"

# Step 2: Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}

# Step 3: Build and push image
echo "🔨 Building and pushing Docker image..."
docker buildx build --platform linux/arm64 -t ${IMAGE_URI} --push .

# Step 4: Verify the push
echo "✅ Verifying deployment..."
aws ecr describe-images --repository-name ${REPOSITORY_NAME} --region ${REGION}

echo "🎉 Deployment complete! Image available at: ${IMAGE_URI}"

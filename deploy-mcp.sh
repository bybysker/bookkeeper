# Variables
REGION="us-east-1"
ACCOUNT_ID=""
REPO_NAME="mcp-gitlab"
IMAGE="mcp/gitlab"

# Create ECR repository if it does not exist
aws ecr describe-repositories --repository-names "$REPO_NAME" --region $REGION --output json >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ECR repository $REPO_NAME does not exist. Creating..."
  aws ecr create-repository --repository-name "$REPO_NAME" --region $REGION
else
  echo "ECR repository $REPO_NAME already exists."
fi

# Authentification
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Pull, tag et push
docker pull $IMAGE
docker tag $IMAGE $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
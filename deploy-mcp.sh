# Variables
REGION="us-east-1"
ACCOUNT_ID=""
REPO_NAME="mcp-gitlab"
IMAGE="mcp/gitlab"

# Authentification
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Pull, tag et push
docker pull $IMAGE
docker tag $IMAGE $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
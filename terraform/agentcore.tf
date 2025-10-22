# Random suffix for unique resource naming
resource "random_id" "suffix" {
  byte_length = 4
}

# ECR Repository for Agent Runtime
resource "awscc_ecr_repository" "agent_runtime" {
  repository_name = "bedrock/agent-runtime-${random_id.suffix.hex}"

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }, {
    key   = "Environment"
    value = var.environment
  }, {
    key   = "Project"
    value = "bookkeeper"
  }]
}

# IAM role for Agent Runtime
resource "awscc_iam_role" "agent_runtime_role" {
  role_name = "bedrock-agent-runtime-role-${random_id.suffix.hex}"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
      }
    ]
  })

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }, {
    key   = "Environment"
    value = var.environment
  }, {
    key   = "Project"
    value = "bookkeeper"
  }]
}

# IAM policy for Agent Runtime
resource "awscc_iam_role_policy" "agent_runtime_policy" {
  role_name   = awscc_iam_role.agent_runtime_role.role_name
  policy_name = "bedrock-agent-runtime-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:bookkeeper/*"
      }
    ]
  })
}

# Bedrock Agent Core Runtime
resource "awscc_bedrockagentcore_runtime" "bookkeeper" {
  agent_runtime_name = "bookkeeper_agent_runtime_${random_id.suffix.hex}"
  description        = "Bookkeeper Bedrock Agent Runtime for multi-agent orchestration"
  role_arn           = awscc_iam_role.agent_runtime_role.arn

  agent_runtime_artifact = {
    container_configuration = {
      container_uri = "${awscc_ecr_repository.agent_runtime.repository_uri}:latest"
    }
  }

  network_configuration = {
    network_mode = "PUBLIC" # will be modified to use VPC constraints once available
  }

  environment_variables = {
    "LOG_LEVEL"                      = "INFO"
    "AWS_REGION"                     = var.aws_region
    "KNOWLEDGE_BASE_ID"              = aws_bedrockagent_knowledge_base.bookkeeper_kb.id
    "S3_BUCKET"                      = aws_s3_bucket.knowledge_base_data.bucket
    "ENVIRONMENT"                    = var.environment
    "GITLAB_API_URL"                 = var.gitlab_api_url
    "GITLAB_PERSONAL_ACCESS_TOKEN"   = aws_secretsmanager_secret.gitlab_token.arn
    "LANGFUSE_HOST"                  = var.langfuse_host
    "LANGFUSE_PUBLIC_KEY"            = aws_secretsmanager_secret.langfuse_public_key.arn
    "LANGFUSE_SECRET_KEY"            = aws_secretsmanager_secret.langfuse_secret_key.arn
  }

  tags = {
    "Modified By" = "AWSCC"
    "Environment" = var.environment
    "Project"     = "bookkeeper"
  }
}


# AWS Secrets Manager secrets for Agent Runtime

# GitLab Personal Access Token
resource "aws_secretsmanager_secret" "gitlab_token" {
  name        = "bookkeeper/gitlab-personal-access-token-${random_id.suffix.hex}"
  description = "GitLab Personal Access Token for Bookkeeper Agent Runtime"

  recovery_window_in_days = 7

  tags = {
    Name        = "bookkeeper-gitlab-token"
    Environment = var.environment
    Project     = "bookkeeper"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "gitlab_token" {
  secret_id     = aws_secretsmanager_secret.gitlab_token.id
  secret_string = "PLACEHOLDER_UPDATE_AFTER_DEPLOYMENT"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Langfuse Public Key
resource "aws_secretsmanager_secret" "langfuse_public_key" {
  name        = "bookkeeper/langfuse-public-key-${random_id.suffix.hex}"
  description = "Langfuse Public Key for Bookkeeper Agent Runtime"

  recovery_window_in_days = 7

  tags = {
    Name        = "bookkeeper-langfuse-public-key"
    Environment = var.environment
    Project     = "bookkeeper"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "langfuse_public_key" {
  secret_id     = aws_secretsmanager_secret.langfuse_public_key.id
  secret_string = "PLACEHOLDER_UPDATE_AFTER_DEPLOYMENT"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Langfuse Secret Key
resource "aws_secretsmanager_secret" "langfuse_secret_key" {
  name        = "bookkeeper/langfuse-secret-key-${random_id.suffix.hex}"
  description = "Langfuse Secret Key for Bookkeeper Agent Runtime"

  recovery_window_in_days = 7

  tags = {
    Name        = "bookkeeper-langfuse-secret-key"
    Environment = var.environment
    Project     = "bookkeeper"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "langfuse_secret_key" {
  secret_id     = aws_secretsmanager_secret.langfuse_secret_key.id
  secret_string = "PLACEHOLDER_UPDATE_AFTER_DEPLOYMENT"

  lifecycle {
    ignore_changes = [secret_string]
  }
}


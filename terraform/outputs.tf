output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.my_strands_agent.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.my_strands_agent.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.my_strands_agent.name
}

output "ecr_registry_id" {
  description = "Registry ID of the ECR repository"
  value       = aws_ecr_repository.my_strands_agent.registry_id
}

# Knowledge Base Outputs
output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.bookkeeper_kb.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.bookkeeper_kb.arn
}

output "opensearch_collection_endpoint" {
  description = "Endpoint of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.knowledge_base.collection_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for knowledge base data"
  value       = aws_s3_bucket.knowledge_base_data.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for knowledge base data"
  value       = aws_s3_bucket.knowledge_base_data.arn
}

output "data_source_id" {
  description = "ID of the S3 data source"
  value       = aws_bedrockagent_data_source.s3_source.data_source_id
}

# Agent Core Runtime Outputs
output "agent_runtime_ecr_repository_uri" {
  description = "URI of the ECR repository for Agent Runtime"
  value       = awscc_ecr_repository.agent_runtime.repository_uri
}

output "agent_runtime_ecr_repository_name" {
  description = "Name of the ECR repository for Agent Runtime"
  value       = awscc_ecr_repository.agent_runtime.repository_name
}

output "agent_runtime_role_arn" {
  description = "ARN of the IAM role for Agent Runtime"
  value       = awscc_iam_role.agent_runtime_role.arn
}

output "agent_runtime_id" {
  description = "ID of the Bedrock Agent Core Runtime"
  value       = awscc_bedrockagentcore_runtime.bookkeeper.agent_runtime_id
}

output "agent_runtime_name" {
  description = "Name of the Bedrock Agent Core Runtime"
  value       = awscc_bedrockagentcore_runtime.bookkeeper.agent_runtime_name
}

output "agent_runtime_arn" {
  description = "ARN of the Bedrock Agent Core Runtime"
  value       = awscc_bedrockagentcore_runtime.bookkeeper.agent_runtime_arn
}

# Secrets Manager Outputs
output "gitlab_token_secret_arn" {
  description = "ARN of the GitLab Personal Access Token secret"
  value       = aws_secretsmanager_secret.gitlab_token.arn
}

output "gitlab_token_secret_name" {
  description = "Name of the GitLab Personal Access Token secret"
  value       = aws_secretsmanager_secret.gitlab_token.name
}

output "langfuse_public_key_secret_arn" {
  description = "ARN of the Langfuse Public Key secret"
  value       = aws_secretsmanager_secret.langfuse_public_key.arn
}

output "langfuse_public_key_secret_name" {
  description = "Name of the Langfuse Public Key secret"
  value       = aws_secretsmanager_secret.langfuse_public_key.name
}

output "langfuse_secret_key_secret_arn" {
  description = "ARN of the Langfuse Secret Key secret"
  value       = aws_secretsmanager_secret.langfuse_secret_key.arn
}

output "langfuse_secret_key_secret_name" {
  description = "Name of the Langfuse Secret Key secret"
  value       = aws_secretsmanager_secret.langfuse_secret_key.name
}

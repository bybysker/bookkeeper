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
  value       = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.main.arn
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

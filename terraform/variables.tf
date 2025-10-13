variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "strands-agent"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Knowledge Base Variables
variable "knowledge_base_name" {
  description = "Name of the Bedrock Knowledge Base"
  type        = string
  default     = "customer-support"
}

variable "knowledge_base_description" {
  description = "Description of the Bedrock Knowledge Base"
  type        = string
  default     = "Knowledge base for customer support using S3 agent"
}

variable "opensearch_collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  type        = string
  default     = "kb-collection"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for knowledge base data"
  type        = string
  default     = "kb-data-source"
}

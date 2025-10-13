# Example Terraform variables file
# Copy this to terraform.tfvars and customize as needed

aws_region      = "us-east-1"
repository_name = "strands-agent"
environment     = "production"

# Knowledge Base Configuration
knowledge_base_name        = "customer-support"
knowledge_base_description = "Knowledge base for customer support using S3 agent"
opensearch_collection_name = "kb-collection-ter"
s3_bucket_name            = "kb-data-source-ter"

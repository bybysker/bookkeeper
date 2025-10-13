# S3 Bucket for Knowledge Base Data Source
resource "aws_s3_bucket" "knowledge_base_data" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
    Project     = "bookkeeper"
    Purpose     = "bedrock-knowledge-base-data"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "knowledge_base_data" {
  bucket = aws_s3_bucket.knowledge_base_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base_data" {
  bucket = aws_s3_bucket.knowledge_base_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "knowledge_base_data" {
  bucket = aws_s3_bucket.knowledge_base_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for Bedrock Access
resource "aws_s3_bucket_policy" "knowledge_base_data" {
  bucket = aws_s3_bucket.knowledge_base_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockKnowledgeBaseAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.bedrock_knowledge_base_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.knowledge_base_data.arn,
          "${aws_s3_bucket.knowledge_base_data.arn}/*"
        ]
      }
    ]
  })
}

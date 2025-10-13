# IAM Role for Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  name = "${var.knowledge_base_name}-bedrock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.knowledge_base_name}-bedrock-role"
    Environment = var.environment
    Project     = "bookkeeper"
    Purpose     = "bedrock-knowledge-base"
  }
}

# IAM Policy for Bedrock Knowledge Base
resource "aws_iam_policy" "bedrock_knowledge_base_policy" {
  name        = "${var.knowledge_base_name}-bedrock-policy"
  description = "Policy for Bedrock Knowledge Base to access S3 and OpenSearch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.knowledge_base_data.arn,
          "${aws_s3_bucket.knowledge_base_data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll",
          "aoss:CreateCollectionItems",
          "aoss:DeleteCollectionItems",
          "aoss:UpdateCollectionItems",
          "aoss:DescribeCollectionItems"
        ]
        Resource = aws_opensearchserverless_collection.knowledge_base.arn
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"
        ]
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_attachment" {
  role       = aws_iam_role.bedrock_knowledge_base_role.name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy.arn
}

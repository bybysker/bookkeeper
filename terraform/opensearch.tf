# OpenSearch Serverless Collection for Bedrock Knowledge Base
resource "aws_opensearchserverless_collection" "knowledge_base" {
  name        = var.opensearch_collection_name
  description = "OpenSearch Serverless collection for Bedrock Knowledge Base"
  type        = "VECTORSEARCH"

  tags = {
    Name        = var.opensearch_collection_name
    Environment = var.environment
    Project     = "bookkeeper"
    Purpose     = "bedrock-knowledge-base"
  }

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

# Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = "${var.opensearch_collection_name}-encryption"
  type        = "encryption"
  description = "Encryption policy for Bedrock Knowledge Base collection"

  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.opensearch_collection_name}"
        ]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

# Network Security Policy (Public Access)
resource "aws_opensearchserverless_security_policy" "network" {
  name        = "${var.opensearch_collection_name}-network"
  type        = "network"
  description = "Network policy for Bedrock Knowledge Base collection"

  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for Bedrock Knowledge Base"
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${var.opensearch_collection_name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.opensearch_collection_name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# Data Access Policy for Bedrock
resource "aws_opensearchserverless_access_policy" "bedrock_access" {
  name        = "${var.opensearch_collection_name}-kb-access"
  type        = "data"
  description = "Data access policy for Bedrock Knowledge Base"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${var.opensearch_collection_name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          ResourceType = "index"
          Resource = [
            "index/${var.opensearch_collection_name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        }
      ]
      Principal = [
        aws_iam_role.bedrock_knowledge_base_role.arn,
        "arn:aws:iam::286830035804:root"
      ]
    }
  ])
}

# Vector Index for Bedrock Knowledge Base
resource "opensearch_index" "bedrock_knowledge_base_index" {
  name               = "bedrock-knowledge-base-default-index"
  number_of_shards   = 1
  number_of_replicas = 0
  index_knn          = true
  index_knn_algo_param_ef_search = "512"
  
  mappings = jsonencode({
    properties = {
      "bedrock-knowledge-base-default-vector" = {
        type = "knn_vector"
        dimension = 1024
        method = {
          name = "hnsw"
          space_type = "l2"
          engine = "faiss"
          parameters = {
            ef_construction = 512
            m = 16
          }
        }
      }
      "AMAZON_BEDROCK_TEXT_CHUNK" = {
        type = "text"
      }
      "AMAZON_BEDROCK_METADATA" = {
        type = "text"
      }
    }
  })

  depends_on = [
    aws_opensearchserverless_collection.knowledge_base,
    aws_opensearchserverless_access_policy.bedrock_access
  ]
}

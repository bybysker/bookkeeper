# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "main" {
  name        = var.knowledge_base_name
  description = var.knowledge_base_description
  role_arn    = aws_iam_role.bedrock_knowledge_base_role.arn

  depends_on = [
    opensearch_index.bedrock_knowledge_base_index
  ]

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.knowledge_base.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  tags = {
    Name        = var.knowledge_base_name
    Environment = var.environment
    Project     = "bookkeeper"
  }
}

# S3 Data Source for Knowledge Base
resource "aws_bedrockagent_data_source" "s3_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  name              = "${var.knowledge_base_name}-s3-source"
  description       = "S3 data source for ${var.knowledge_base_name} knowledge base"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledge_base_data.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens        = 300
        overlap_percentage = 20
      }
    }
  }

#   tags = {
#     Name        = "${var.knowledge_base_name}-s3-source"
#     Environment = var.environment
#     Project     = "bookkeeper"
#   }
}

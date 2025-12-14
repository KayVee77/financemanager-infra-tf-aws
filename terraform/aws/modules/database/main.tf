# =============================================================================
# Database Module - DynamoDB Tables
# =============================================================================
# Creates DynamoDB tables for transactions and categories storage.

# -----------------------------------------------------------------------------
# Transactions Table
# -----------------------------------------------------------------------------

resource "aws_dynamodb_table" "transactions" {
  name         = "${var.name_prefix}-transactions"
  billing_mode = "PAY_PER_REQUEST" # On-demand for thesis (cost-effective)
  hash_key     = "userId"
  range_key    = "transactionId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "transactionId"
    type = "S"
  }

  # Enable point-in-time recovery (optional, good practice)
  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  # Server-side encryption (using AWS managed key)
  server_side_encryption {
    enabled = true
  }

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Categories Table
# -----------------------------------------------------------------------------

resource "aws_dynamodb_table" "categories" {
  name         = "${var.name_prefix}-categories"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "categoryId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "categoryId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.common_tags
}

resource "aws_dynamodb_table" "url_table" {
  name           = "${var.project_name}-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "shortCode"

  attribute {
    name = "shortCode"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-table"
    Environment = var.environment
    Project     = var.project_name
  }
}
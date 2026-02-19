# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.url_table.arn,
          "${aws_dynamodb_table.url_table.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Zip the Lambda functions
data "archive_file" "create_url" {
  type        = "zip"
  source_file = "${path.module}/../../backend/src/create_url.py"
  output_path = "${path.module}/../../backend/create_url.zip"
}

data "archive_file" "get_url" {
  type        = "zip"
  source_file = "${path.module}/../../backend/src/get_url.py"
  output_path = "${path.module}/../../backend/get_url.zip"
}

data "archive_file" "list_urls" {
  type        = "zip"
  source_file = "${path.module}/../../backend/src/list_urls.py"
  output_path = "${path.module}/../../backend/list_urls.zip"
}

data "archive_file" "delete_url" {
  type        = "zip"
  source_file = "${path.module}/../../backend/src/delete_url.py"
  output_path = "${path.module}/../../backend/delete_url.zip"
}

# Lambda Functions
resource "aws_lambda_function" "create_url" {
  filename         = data.archive_file.create_url.output_path
  function_name    = "${var.project_name}-create-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_url.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.create_url.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
    }
  }
}

resource "aws_lambda_function" "get_url" {
  filename         = data.archive_file.get_url.output_path
  function_name    = "${var.project_name}-get-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_url.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.get_url.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
    }
  }
}

resource "aws_lambda_function" "list_urls" {
  filename         = data.archive_file.list_urls.output_path
  function_name    = "${var.project_name}-list-urls"
  role             = aws_iam_role.lambda_role.arn
  handler          = "list_urls.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.list_urls.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
    }
  }
}

resource "aws_lambda_function" "delete_url" {
  filename         = data.archive_file.delete_url.output_path
  function_name    = "${var.project_name}-delete-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "delete_url.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.delete_url.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
    }
  }
}
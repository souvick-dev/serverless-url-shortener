# Create REST API
resource "aws_api_gateway_rest_api" "url_api" {
  name        = "${var.project_name}-api"
  description = "Serverless URL Shortener API"
}

# /urls resource
resource "aws_api_gateway_resource" "urls" {
  rest_api_id = aws_api_gateway_rest_api.url_api.id
  parent_id   = aws_api_gateway_rest_api.url_api.root_resource_id
  path_part   = "urls"
}

# /urls/{shortCode} resource
resource "aws_api_gateway_resource" "url_shortcode" {
  rest_api_id = aws_api_gateway_rest_api.url_api.id
  parent_id   = aws_api_gateway_resource.urls.id
  path_part   = "{shortCode}"
}

# POST /urls - Create URL
resource "aws_api_gateway_method" "create_url" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.urls.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_url" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.urls.id
  http_method             = aws_api_gateway_method.create_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_url.invoke_arn
}

# GET /urls - List URLs
resource "aws_api_gateway_method" "list_urls" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.urls.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_urls" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.urls.id
  http_method             = aws_api_gateway_method.list_urls.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_urls.invoke_arn
}

# GET /urls/{shortCode} - Get URL
resource "aws_api_gateway_method" "get_url" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.url_shortcode.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_url" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.url_shortcode.id
  http_method             = aws_api_gateway_method.get_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_url.invoke_arn
}

# DELETE /urls/{shortCode} - Delete URL
resource "aws_api_gateway_method" "delete_url" {
  rest_api_id   = aws_api_gateway_rest_api.url_api.id
  resource_id   = aws_api_gateway_resource.url_shortcode.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_url" {
  rest_api_id             = aws_api_gateway_rest_api.url_api.id
  resource_id             = aws_api_gateway_resource.url_shortcode.id
  http_method             = aws_api_gateway_method.delete_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_url.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "url_api" {
  depends_on = [
    aws_api_gateway_integration.create_url,
    aws_api_gateway_integration.list_urls,
    aws_api_gateway_integration.get_url,
    aws_api_gateway_integration.delete_url
  ]
  rest_api_id = aws_api_gateway_rest_api.url_api.id
  stage_name  = "dev"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "create_url" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "list_urls" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_urls.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_url" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_url" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_api.execution_arn}/*/*"
}

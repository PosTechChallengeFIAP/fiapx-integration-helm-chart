resource "aws_api_gateway_rest_api" "user_management_api" {
  name        = "user-management-api"
  description = "FIAPX User Management REST API for EKS via NLB"
}

resource "aws_api_gateway_vpc_link" "user_management_vpc_link" {
  name        = "user-management-vpc-link"
  target_arns = [var.user_management_nlb_arn]  # Replace with your actual NLB ARN
}

resource "aws_api_gateway_resource" "user_management_proxy" {
  rest_api_id = aws_api_gateway_rest_api.user_management_api.id
  parent_id   = aws_api_gateway_rest_api.user_management_api.root_resource_id
  path_part   = "{proxy+}"
}

# Methods
resource "aws_api_gateway_method" "user_management_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.user_management_api.id
  resource_id   = aws_api_gateway_resource.user_management_proxy.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "user_management_proxy_post" {
  rest_api_id   = aws_api_gateway_rest_api.user_management_api.id
  resource_id   = aws_api_gateway_resource.user_management_proxy.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "user_management_proxy_put" {
  rest_api_id   = aws_api_gateway_rest_api.user_management_api.id
  resource_id   = aws_api_gateway_resource.user_management_proxy.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Integrations
resource "aws_api_gateway_integration" "user_management_proxy_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_management_api.id
  resource_id             = aws_api_gateway_resource.user_management_proxy.id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.user_management_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.user_management_vpc_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.user_management_proxy_get]
}

resource "aws_api_gateway_integration" "user_management_proxy_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_management_api.id
  resource_id             = aws_api_gateway_resource.user_management_proxy.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.user_management_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.user_management_vpc_link.id
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.user_management_proxy_post]
}

resource "aws_api_gateway_integration" "user_management_proxy_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_management_api.id
  resource_id             = aws_api_gateway_resource.user_management_proxy.id
  http_method             = "PUT"
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.user_management_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.user_management_vpc_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.user_management_proxy_put]
}

resource "aws_api_gateway_deployment" "user_management_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.user_management_api.id

  depends_on = [
    aws_api_gateway_integration.user_management_proxy_get_integration,
    aws_api_gateway_integration.user_management_proxy_post_integration,
    aws_api_gateway_integration.user_management_proxy_put_integration
  ]
}

resource "aws_api_gateway_stage" "user_management_api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.user_management_api.id
  deployment_id = aws_api_gateway_deployment.user_management_api_deployment.id
}

output "user_management_api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.user_management_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}
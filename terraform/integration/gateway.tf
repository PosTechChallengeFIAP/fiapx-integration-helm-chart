resource "aws_api_gateway_rest_api" "eks_rest_api" {
  name        = "eks-rest-api"
  description = "REST API for EKS via NLB"
}

resource "aws_api_gateway_vpc_link" "eks_vpc_link" {
  name        = "eks-vpc-link"
  target_arns = [var.nlb_arn]  # Replace with your actual NLB ARN
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.eks_rest_api.id
  parent_id   = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

# Methods
resource "aws_api_gateway_method" "proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_post" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_put" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "PUT"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "proxy_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.proxy_get]
}

resource "aws_api_gateway_integration" "proxy_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.proxy_post]
}

resource "aws_api_gateway_integration" "proxy_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = "PUT"
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.proxy_put]
}

# Methods
resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "root_post" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "root_put" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method   = "PUT"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "root_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.root_get]
}

resource "aws_api_gateway_integration" "root_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.root_post]
}

resource "aws_api_gateway_integration" "root_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_rest_api.eks_rest_api.root_resource_id
  http_method             = "PUT"
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id

  depends_on = [aws_api_gateway_method.root_put]
}

resource "aws_api_gateway_deployment" "eks_deployment" {
  rest_api_id = aws_api_gateway_rest_api.eks_rest_api.id

  depends_on = [
    aws_api_gateway_integration.proxy_get_integration,
    aws_api_gateway_integration.proxy_post_integration,
    aws_api_gateway_integration.proxy_put_integration,
    aws_api_gateway_integration.root_get_integration,
    aws_api_gateway_integration.root_post_integration,
    aws_api_gateway_integration.root_put_integration
  ]
}

resource "aws_api_gateway_stage" "eks_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  deployment_id = aws_api_gateway_deployment.eks_deployment.id
}

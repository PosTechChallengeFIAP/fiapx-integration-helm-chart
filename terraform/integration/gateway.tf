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

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.eks_rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns}:80"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks_vpc_link.id
}

resource "aws_api_gateway_deployment" "eks_deployment" {
  rest_api_id = aws_api_gateway_rest_api.eks_rest_api.id

  depends_on  = [aws_api_gateway_integration.proxy_integration]
}

resource "aws_api_gateway_stage" "eks_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.eks_rest_api.id
  deployment_id = aws_api_gateway_deployment.eks_deployment.id
}
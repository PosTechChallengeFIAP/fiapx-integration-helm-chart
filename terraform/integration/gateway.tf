resource "aws_apigatewayv2_api" "eks_http_api" {
  name          = "eks-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS", "DELETE", "PATCH", "PUT"]
    allow_headers = ["content-type", "authorization"]
    max_age = 300
  }
}

resource "aws_security_group" "api_gateway_sg" {
  name        = "api-gateway-sg"
  description = "Allow API Gateway VPC Link to reach EKS NLB"
  vpc_id      = local.vpc_id

  # Outbound to EKS app 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress typically not needed for VPC Link
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all temporarily (can tighten later)"
  }

  tags = {
    Name = "api-gateway-sg"
  }
}

resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
  name               = "eks-vpc-link"
  subnet_ids         = local.vpc_id
  security_group_ids = [aws_security_group.api_gateway_sg.id]
}

resource "aws_apigatewayv2_integration" "user_management" {
  api_id             = aws_apigatewayv2_api.eks_http_api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = local.cluster_endpoint
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks_vpc_link.id
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.eks_http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks_http_api.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.eks_http_api.id
  name        = "$default"
  auto_deploy = true
}


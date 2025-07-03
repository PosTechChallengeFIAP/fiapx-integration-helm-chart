resource "aws_api_gateway_rest_api" "video_processor_api" {
  name        = "video-processor-api"
  description = "FIAPX Video Processor REST API for EKS via NLB"

  binary_media_types = [
    "multipart/form-data"
  ]
}

resource "aws_api_gateway_vpc_link" "video_processor_vpc_link" {
  name        = "video-processor-vpc-link"
  target_arns = [var.video_processor_nlb_arn]  # Replace with your actual NLB ARN
}

resource "aws_api_gateway_resource" "video_processor_proxy" {
  rest_api_id = aws_api_gateway_rest_api.video_processor_api.id
  parent_id   = aws_api_gateway_rest_api.video_processor_api.root_resource_id
  path_part   = "{proxy+}"
}

# Methods
resource "aws_api_gateway_method" "video_processor_proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.video_processor_api.id
  resource_id   = aws_api_gateway_resource.video_processor_proxy.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "video_processor_proxy_post" {
  rest_api_id   = aws_api_gateway_rest_api.video_processor_api.id
  resource_id   = aws_api_gateway_resource.video_processor_proxy.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "video_processor_proxy_put" {
  rest_api_id   = aws_api_gateway_rest_api.video_processor_api.id
  resource_id   = aws_api_gateway_resource.video_processor_proxy.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Integrations
resource "aws_api_gateway_integration" "video_processor_proxy_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.video_processor_api.id
  resource_id             = aws_api_gateway_resource.video_processor_proxy.id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.video_processor_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.video_processor_vpc_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.video_processor_proxy_get]
}

resource "aws_api_gateway_integration" "video_processor_proxy_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.video_processor_api.id
  resource_id             = aws_api_gateway_resource.video_processor_proxy.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.video_processor_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.video_processor_vpc_link.id
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.video_processor_proxy_post]
}

resource "aws_api_gateway_integration" "video_processor_proxy_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.video_processor_api.id
  resource_id             = aws_api_gateway_resource.video_processor_proxy.id
  http_method             = "PUT"
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.video_processor_nlb_dns}:80/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.video_processor_vpc_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  depends_on = [aws_api_gateway_method.video_processor_proxy_put]
}

resource "aws_api_gateway_deployment" "video_processor_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.video_processor_api.id

  depends_on = [
    aws_api_gateway_integration.video_processor_proxy_get_integration,
    aws_api_gateway_integration.video_processor_proxy_post_integration,
    aws_api_gateway_integration.video_processor_proxy_put_integration
  ]
}

resource "aws_api_gateway_stage" "video_processor_api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.video_processor_api.id
  deployment_id = aws_api_gateway_deployment.video_processor_api_deployment.id
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.video_processor_api_deployment.invoke_url
}

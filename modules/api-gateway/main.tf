resource "aws_api_gateway_rest_api" "api-pipefy" {
  name        = "api-pipefy"
  description = "API para integração com Pipefy"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api-pipefy-resource" {
  rest_api_id = aws_api_gateway_rest_api.api-pipefy.id
  parent_id   = aws_api_gateway_rest_api.api-pipefy.root_resource_id
  path_part   = "receber-chamado"
}

resource "aws_api_gateway_method" "api-pipefy-method" {
  rest_api_id   = aws_api_gateway_rest_api.api-pipefy.id
  resource_id   = aws_api_gateway_resource.api-pipefy-resource.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.filename" = true
  }
}

resource "aws_api_gateway_integration" "api-pipefy-integration" {
  rest_api_id = aws_api_gateway_rest_api.api-pipefy.id
  resource_id = aws_api_gateway_resource.api-pipefy-resource.id
  http_method = aws_api_gateway_method.api-pipefy-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
  credentials             = var.iam_role_arn
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.filename" = "method.request.path.filename"
  }
}

resource "aws_api_gateway_deployment" "api-pipefy-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-pipefy.id
  depends_on  = [
    aws_api_gateway_integration.api-pipefy-integration,
    var.allow_apigw_invoke_api
  ]
}

resource "aws_api_gateway_stage" "api-pipefy-stage" {
  deployment_id = aws_api_gateway_deployment.api-pipefy-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api-pipefy.id
  stage_name    = "prod"
}
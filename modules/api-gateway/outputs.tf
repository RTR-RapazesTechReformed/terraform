output "api_test_url" {
  description = "URL base para fazer testes na API do Pipefy"
  value       = "https://${aws_api_gateway_rest_api.api-pipefy.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.api-pipefy-stage.stage_name}/${var.bronze_bucket_name}/{filename}"
}

output "api_gateway_execution_arn" {
  description = "ARN da execução da API Gateway"
  value       = "${aws_api_gateway_rest_api.api-pipefy.execution_arn}/*/*"
  
}
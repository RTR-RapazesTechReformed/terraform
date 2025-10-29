variable "iam_role_arn" {
  description = "ARN da role IAM para a API Gateway"
  type        = string
}

variable "region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "bronze_bucket_name" {
  description = "Nome do bucket S3 para o armazenamento de dados no nível Bronze"
  type        = string
}

variable "lambda_arn" {
  description = "ARN da função Lambda que processa os dados"
  type        = string
}

variable "allow_apigw_invoke_api" {
  description = "Permissão para a API Gateway invocar a função Lambda"
  type        = any
  
}
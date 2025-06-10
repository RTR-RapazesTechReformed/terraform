terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = ""
  secret_key = ""
  token      = ""
  region     = "us-east-1"
}

module "s3" {
  source = "./modules/s3"
}

module "sns" {
  source     = "./modules/sns"
  email_list = var.email_list
}

module "lambda" {
  source      = "./modules/lambda"
  email_list  = var.email_list
  bronze_arn  = module.s3.bronze_arn
  bronze_name = module.s3.bronze_name
  silver_name = module.s3.silver_name
  silver_arn  = module.s3.silver_arn
  topic_arn   = module.sns.topic_arn
  api_gateway_execution_arn = module.api-gateway.api_gateway_execution_arn
}

module "api-gateway" {
  source             = "./modules/api-gateway"
  iam_role_arn       = var.iam_role_arn
  region             = "us-east-1"
  bronze_bucket_name = module.s3.bronze_name
  lambda_arn         = module.lambda.lambda_function_arn_api
  allow_apigw_invoke_api = module.lambda.allow_apigw_invoke.statement_id
}

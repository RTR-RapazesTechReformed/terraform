terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
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
}
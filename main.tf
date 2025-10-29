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

module "network" {
  source = "./modules/network"
}

module "ec2" {
  source = "./modules/ec2"
  subnet_publica_id        = module.network.subnet_publica_id
  subnet_privada_id        = module.network.subnet_privada_id
  security_group_id_public = module.network.security_group_id_public
  security_group_id_private = module.network.security_group_id_private
  vpc_id                   = module.network.vpc_id
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
  role_arn_aws = var.iam_role_arn
  bronze_arn  = module.s3.bronze_arn
  bronze_name = module.s3.bronze_name
  silver_name = module.s3.silver_name
  silver_arn  = module.s3.silver_arn
  topic_arn   = module.sns.topic_arn
  api_gateway_execution_arn = module.api-gateway.api_gateway_execution_arn
}

module "alb" {
  source                = "./modules/alb"
  security_group_id_alb = module.network.security_group_id_alb
  subnet_ids_publicas   = module.network.subnet_ids_publicas
  vpc_id                = module.network.vpc_id
  front_instance_ids    = module.ec2.front_instance_ids
}
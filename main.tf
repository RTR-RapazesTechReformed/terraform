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
  region = "us-east-1"
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

module "ec2" {
  source = "./modules/ec2"

  subnet_publica_id    = module.network.subnet_publica_id_network
  subnet_privada_id      = module.network.subnet_privada_id_network
  security_group_id_public = module.network.security_group_id_public
  security_group_id_private = module.network.security_group_id_private
  vpc_id                  = module.network.vpc_id
}

module "network" {
  source = "./modules/network"
}
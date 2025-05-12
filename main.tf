terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "./modules/ec2"

  subnet_publica_id       = module.network.subnet_publica_id
  subnet_privada_id       = module.network.subnet_privada_id
  security_group_id_public = module.network.security_group_id_public
  security_group_id_private = module.network.security_group_id_private
  vpc_id                  = module.network.vpc_id
}

module "network" {
  source = "./modules/network"
}
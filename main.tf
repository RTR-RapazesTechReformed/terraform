terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = "" # Acesso a AWS
  secret_key = "" # Chave secreta da AWS
  token      = "" # Token da AWS
  # Todos podem ser pegos do console AWS ao iniciar o Lab e clicar em AWS Details
  region = "us-east-1"
}

module "ec2_instances" {
  source = "./modules/ec2"
}

module "network" {
  source = "./modules/network"
}
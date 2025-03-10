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
  region     = "us-east-1"
}

resource "aws_vpc" "vpc_segura_1" {
  cidr_block = "10.0.0.0/23"

  tags = {
    Name = "VPC_Segura_1"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_segura_1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Subnet_Publica"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id            = aws_vpc.vpc_segura_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet_Privada"
  }
}

resource "aws_internet_gateway" "internet_gw_1" {
  vpc_id = aws_vpc.vpc_segura_1.id

  tags = {
    Name = "Internet_GW_1"
  }
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_segura_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw_1.id
  }

  tags = {
    Name = "RT_Publica"
  }
}

resource "aws_route_table_association" "associacao_rt_publica" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_publica.id

  tags = {
    Name = "NAT_GW_1"
  }
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.vpc_segura_1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }

  tags = {
    Name = "RT_Privada"
  }
}

resource "aws_route_table_association" "associacao_rt_privada" {
  subnet_id      = aws_subnet.subnet_privada.id
  route_table_id = aws_route_table.rt_privada.id
}

resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits = 4096
}

variable "key_name_public" {}
variable "key_name_private" {}

resource "aws_key_pair" "chave_publica" {
  key_name   = var.key_name_public
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "chave_publica_local" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name_public
}

resource "aws_instance" "instancia_publica" {
  ami                         = "ami-029f33a91738d30e9" # Ubuntu 24.04 - US East 1, https://cloud-images.ubuntu.com/locator/ec2/
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_publica.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.chave_publica.key_name

  tags = {
    Name = "Instancia_Publica"
  }
}

resource "aws_key_pair" "chave_privada" {
  key_name   = var.key_name_private
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

resource "local_file" "chave_privada_local" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name_private
}

resource "aws_instance" "instancia_privada" {
  ami           = "ami-029f33a91738d30e9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_privada.id
  key_name      = aws_key_pair.chave_privada.key_name

  tags = {
    Name = "Instancia_Privada"
  }
}
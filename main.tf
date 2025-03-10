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

resource "aws_vpc" "vpc_01" {
  cidr_block       = "10.0.0.0/23"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-01"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sub-pub-01"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sub-priv-01"
  }
}

resource "aws_internet_gateway" "igw_01" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "igw-01"
  }
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "rt-pub-01"
  }
}

resource "aws_route" "rota_publica" {
  route_table_id         = aws_route_table.rt_publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_01.id
}

resource "aws_route_table_association" "rta_publica" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}

resource "aws_eip" "eip_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.subnet_publica.id

  tags = {
    Name = "natgw-01"
  }
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "rt-priv-01"
  }
}

resource "aws_route" "rota_privada" {
  route_table_id         = aws_route_table.rt_privada.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "rta_privada" {
  subnet_id      = aws_subnet.subnet_privada.id
  route_table_id = aws_route_table.rt_privada.id
}

resource "aws_security_group" "public_sg" {
  name        = "launch-wizard-1"
  description = "grupo de seguranca vm publica"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-preview-1"
  }
}

resource "aws_instance" "public_instance" {

  ami = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name = "vm-key-pub-01"
  subnet_id = aws_subnet.subnet_publica.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    delete_on_termination = true
    iops = 3000
    throughput = 125
  }

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_put_response_hop_limit = 2
    http_tokens = "required"
  }

tags = {
    Name = "vm-pub-01"
  }
}

resource "aws_security_group" "launch_wizard_2" {
  name = "launch-wizard-2"
  description = "grupo de seguranca vm privada"
  vpc_id = aws_vpc.vpc_01.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private_instance" {
  ami = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name = "vm-key-priv-01"
  subnet_id = aws_subnet.subnet_privada.id
  vpc_security_group_ids = [aws_security_group.launch_wizard_2.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    delete_on_termination = true
  }

  tags = {
    Name = "vm-priv-01"
  }
}

resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc_01.id
  tags = {
    Name = "acl-pub-01"
  }
}

# Regras de Saída (Egress) para ACL Pública
resource "aws_network_acl_rule" "public_egress_allow_all" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Regras de Entrada (Ingress) para ACL Pública
resource "aws_network_acl_rule" "public_ingress_ssh" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_http" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_ingress_https" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_ingress_ephemeral" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 32000
  to_port        = 65535
}

resource "aws_network_acl_association" "public" {
  subnet_id       = aws_subnet.subnet_publica.id
  network_acl_id  = aws_network_acl.public_acl.id
}

resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.vpc_01.id
  tags = {
    Name = "acl-priv-01"
  }
}

# Regras de Saída (Egress) para ACL Privada
resource "aws_network_acl_rule" "private_egress_allow_all" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Regras de Entrada (Ingress) para ACL Privada
resource "aws_network_acl_rule" "private_ingress_ssh" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_ingress_mysql" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "private_ingress_http" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_ingress_https" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 443
  to_port        = 443
}

# Associação da ACL Privada à subnet privada
resource "aws_network_acl_association" "private" {
  subnet_id       = aws_subnet.subnet_privada.id
  network_acl_id  = aws_network_acl.private_acl.id
}
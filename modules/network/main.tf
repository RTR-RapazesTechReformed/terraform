resource "aws_vpc" "vpc_01" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-store-manager"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = var.subnet_publica_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "sub-pub-store-manager"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = var.subnet_privada_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "sub-priv-store-manager"
  }
}

resource "aws_internet_gateway" "igw_01" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "igw-store-manager"
  }
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "rt-pub-store-manager"
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
    Name = "natgw-store-manager"
  }
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "rt-priv-store-manager"
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

resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc_01.id
  tags = {
    Name = "acl-pub-store-manager"
  }
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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32000
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-store-manager-pub"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "launch-wizard-2"
  description = "grupo de seguranca vm privada"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  subnet_id      = aws_subnet.subnet_publica.id
  network_acl_id = aws_network_acl.public_acl.id
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
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "private_ingress_http" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_ingress_https" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_ingress_ephemeral" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 32000
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_ingress_http2" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 600
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/24"
  from_port      = 8080
  to_port        = 8080
}

# Associação da ACL Privada à subnet privada
resource "aws_network_acl_association" "private" {
  subnet_id      = aws_subnet.subnet_privada.id
  network_acl_id = aws_network_acl.private_acl.id
}
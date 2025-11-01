locals {
  public_instance_config = {
    "vm-front-pub-1" = {
      subnet_id         = var.subnet_publica_id_1
      availability_zone = var.availability_zone
    }
    "vm-front-pub-2" = {
      subnet_id         = var.subnet_publica_id_2
      availability_zone = var.availability_zone_2
    }
    "vm-back-pub-3" = {
      subnet_id         = var.subnet_publica_id_1
      availability_zone = var.availability_zone
    }
  }
}

resource "aws_key_pair" "generated_key_public" {
  key_name   = var.key_pair_name_public
  public_key = file("keypair-public.pem.pub")
}

resource "aws_key_pair" "generated_key_private" {
  key_name   = var.key_pair_name_private
  public_key = file("keypair-private.pem.pub")
}

resource "aws_instance" "public_instance" {
  for_each                    = local.public_instance_config
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key_public.key_name
  subnet_id                   = each.value.subnet_id
  availability_zone           = each.value.availability_zone
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id_public]
  iam_instance_profile        = "LabInstanceProfile"

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    iops                  = 3000
    throughput            = 125
  }

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tags = {
    Name = each.key
  }
}

resource "aws_instance" "private_instance" {
  for_each                    = toset(var.private_instance_names)
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key_private.key_name
  subnet_id                   = var.subnet_privada_id
  vpc_security_group_ids      = [var.security_group_id_private]
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  tags = {
    Name = each.key
  }
}
resource "aws_key_pair" "generated_key_public" {
  key_name   = var.key_pair_name_public
  public_key = file("keypair-public.pem.pub")
}

resource "aws_key_pair" "generated_key_private" {
  key_name   = var.key_pair_name_private
  public_key = file("keypair-private.pem.pub")
}

resource "aws_instance" "public_instance" {

  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key_public.key_name
  subnet_id                   = var.subnet_publica_id
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
    Name = "vm-pub-cynthias-codex"
  }
}

resource "aws_instance" "private_instance" {
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
    Name = "vm-priv-cynthias-codex"
  }
}
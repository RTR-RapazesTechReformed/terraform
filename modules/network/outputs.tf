output "example_output" {
  value = "This is an example output from the network module"
}

output "vpc_id" {
  value = aws_vpc.vpc_01.id
}

output "subnet_publica_id" {
  value = aws_subnet.subnet_publica.id
}

output "subnet_privada_id" {
  value = aws_subnet.subnet_privada.id
}

output "security_group_id_public" {
  value = aws_security_group.public_sg.id
}

output "security_group_id_private" {
  value = aws_security_group.private_sg.id
}
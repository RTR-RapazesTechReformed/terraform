output "vpc_id" {
  value = aws_vpc.vpc_01.id
}

output "security_group_id_public" {
  value = aws_security_group.public_sg.id
}

output "security_group_id_private" {
  value = aws_security_group.private_sg.id
}

output "subnet_privada_id" {
  value = aws_subnet.subnet_privada.id
}

output "subnet_publica_id_1" {
  value = aws_subnet.subnet_publica_1.id
}

output "subnet_publica_id_2" {
  value = aws_subnet.subnet_publica_2.id
}

output "subnet_ids_publicas" {
  value = [
    aws_subnet.subnet_publica_1.id,
    aws_subnet.subnet_publica_2.id
  ]
}
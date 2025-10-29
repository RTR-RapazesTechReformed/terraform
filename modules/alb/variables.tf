variable "security_group_id_alb" {
  description = "ID do Security Group para o ALB"
  type        = string
}

variable "subnet_ids_publicas" {
  description = "Lista de IDs das subnets públicas"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "front_instance_ids" {
  description = "Mapa com os IDs das instâncias front-end"
  type        = map(string)
}
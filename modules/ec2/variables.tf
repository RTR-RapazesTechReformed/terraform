variable "key_pair_name_public" {
  description = "Name of the key pair to be created for public instance"
  type        = string
  default     = "pub_keypair"
}

variable "key_pair_name_private" {
  description = "Name of the key pair to be created for private instance"
  type        = string
  default     = "priv_keypair"
}

variable "subnet_publica_id_1" {
  description = "ID of the public subnet where the EC2 instance will be launched"
  type        = string

}

variable "subnet_publica_id_2" {
  description = "ID of the public subnet where the EC2 instance will be launched"
  type        = string

}

variable "subnet_privada_id" {
  description = "ID of the private subnet where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id_public" {
  description = "ID of the security group for the public EC2 instance"
  type        = string
}

variable "security_group_id_private" {
  description = "ID of the security group for the private EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EC2 instances will be launched"
  type        = string
}

variable "public_instance_count" {
  description = "Quantidade de instâncias públicas"
  type        = number
  default     = 3
}

variable "private_instance_count" {
  description = "Quantidade de instâncias privadas"
  type        = number
  default     = 1
}

variable "public_instance_names" {
  description = "Nomes das instâncias públicas"
  type        = list(string)
  default     = ["vm-front-pub-1", "vm-front-pub-2", "vm-back-pub-3"]
}

variable "private_instance_names" {
  description = "Nomes das instâncias privadas"
  type        = list(string)
  default     = ["vm-bd-priv-1"]
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1b"
}
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

variable "subnet_publica_id" {}
variable "subnet_privada_id" {}
variable "security_group_id_public" {}
variable "security_group_id_private" {}
variable "vpc_id" {}
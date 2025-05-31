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

variable "subnet_publica" {
  description = "ID of the public subnet where the EC2 instance will be launched"
  type        = string

}
variable "subnet_privada" {
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
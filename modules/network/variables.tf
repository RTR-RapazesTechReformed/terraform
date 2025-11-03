variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/22"
}

variable "subnet_publica_1_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_publica_2_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_privada_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
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
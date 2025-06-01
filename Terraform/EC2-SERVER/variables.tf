variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "vpc_name" {
  description = "VPC NAME"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets cidr"
  type        = list(string)
}

variable "private_subnets" {
  description = "Public subnets cidr"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}
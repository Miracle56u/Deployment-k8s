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

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}
variable "vpc_cidr" {
  type = string
}

variable "project_name" {
  type = string 
}

variable "environment" {
  type = string 
}

variable "common_tags" {
  default = {}
}

variable "vpc_tags" {
  default = {}
}

variable "igw_tags" {
  default = {}
}

variable "public_subnet_cidrs" {
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "must have 2 cidrs"
  }
}

variable "private_subnet_cidrs" {
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "must have 2 cidrs"
  }
}

variable "database_subnet_cidrs" {
  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "must have 2 cidrs"
  }
}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_tags" {
  default = {}
}

variable "database_subnet_tags" {
  default = {} 
}

variable "db_subnet_group_tags" {
  default = {}
}

variable "nat_tags" {
  default = {}
}

variable "is_peering_required" {
 type = bool
 default = false
}
variable "vpc_peering_tags" {
  default = {}
}

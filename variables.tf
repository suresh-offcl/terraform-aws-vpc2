variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "common_tags" {
  default = {}
}

variable "vpc_tags" {
  default = {}
}

variable "project_name" {
  
}
variable "environment" {
  
}

variable "igw_tags" {
  default = {}
}
variable "public_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "must have 2 cidr blocks"
  }

}

variable "private_subnet_cidrs" {
    type = list

  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "must have 2 cidr blocks"
  }

}

variable "database_subnet_cidrs" {
    type = list

  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "must have 2 cidr blocks"
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

variable "aws_routeTable_publicTags" {
  default = {}
}

variable "aws_routeTable_privateTags" {
  default = {}
}
variable "aws_routeTable_databaseTags" {
  default = {}
}

variable "eip_tags" {
  default = {}
}

variable "db_group_tags" {
  default = {}
}


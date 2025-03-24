variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "enable_dns_support" {
  
  default = true 

}

variable "enable_dns_hostnames" {
  default = true
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

variable "public_subnet_cidr" {

   type = list
   validation {

     condition = length(var.public_subnet_cidr) ==2
     error_message = "must should have 2 cidr blocks"

   }

}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_cidr" {
   type = list
   validation {

     condition = length(var.private_subnet_cidr) == 2
     error_message = "must should have 2 cidr blocks" 

   }
}

variable "private_subnet_tags" {
  default = {}
}

variable "database_subnet_cidr" {
   type = list
   validation {

     condition = length(var.database_subnet_cidr) == 2
     error_message = "must should have 2 cidr blocks"

   }
}

variable "database_subnet_tags" {
  default = {}
}

variable "route_table_public_tags" {
  default = {}
}

variable "route_table_private_tags" {
  default = {}
}

variable "route_table_database_tags" {
  default = {}
}


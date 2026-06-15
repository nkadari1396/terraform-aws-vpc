variable "vpc_cidr" {
   # default = {}
}

variable "enable_dns_hostnames" {
    default = "true"
}

variable "common_tags" {
    default = {}
}

variable "vpc_tags" {
    default = {}
}

variable "project_name" {
    default = {}
}

variable "environment" {
    default = {}
}

variable "igw_tags" {
    default = {}
}

variable "public_subnet_cidrs" {
    type = list                                                                           #It forces the user to pass exactly 2 CIDR blocks in this variable.
    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid public public subnet CIDR"
    }
}

variable "public_subnets_tags" {
    default = {}
}

variable "private_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "please provide 2 valid public public subnet CIDR"
    }
}

variable "private_subnets_tags" {
    default = {}
}

variable "database_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "please provide 2 valid public public subnet CIDR"
    }
}

variable "database_subnets_tags" {
    default = {}
}

variable "aws_db_subnet_group_tags" {
    default = {}
}

variable "aws_nat_gateway_tags" {
    default = {}
}

variable "public_route_table_tags" {
    default = {}
}

variable "private_route_table_tags" {
    default = {}
}

variable "database_route_table_tags" {
    default = {}
}

variable "is_peering_required" {
    type = bool
    default = false
}

variable "vpc_peering_tags"  {
    default = {}
}

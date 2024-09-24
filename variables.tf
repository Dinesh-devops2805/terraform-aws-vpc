variable "project_name"{
    type = string
}

variable "environment"{
    type = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames"{
    default = true
}


#optional
variable "common_tags"{
    default = {
    }
}
#optional
variable "vpc_tags"{
    default = {

    }
}

variable "igw_tags"{
    default = {

    }
}

variable "public_subnet_cidrs"{
    type = list 
    validation {
        condition = length(var.public_subnet_cidrs) == 2 
        error_message = "please provide the 2 valid public subnet CIDR"
    }
}

variable "public_subnet_tags"{
    default = {     
    }
}

variable "private_subnet_cidrs"{
    type = list 
    validation {
        condition = length(var.private_subnet_cidrs) == 2 
        error_message = "please provide the 2 valid private subnet CIDR"
    }
}

variable "private_subnet_tags"{
    default = {     
    }
}

variable "database_subnet_cidrs"{
    type = list 
    validation {
        condition = length(var.database_subnet_cidrs) == 2 
        error_message = "please provide the 2 valid database subnet CIDR"
    }
}

variable "database_subnet_tags"{
    default = {     
    }
}

variable "db_subnet_group_tags"{
    default = {}
}

variable "nat_gatway_tags"{
    default = {}
}
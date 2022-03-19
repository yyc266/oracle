variable "region" {
  description = "region"
  default     = "cn-north-4"
  type        = string
}

variable "access_key" {
  description = "access_key"
  default     = "RI9VZLDJNNBWBEDVNSC3"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  default     = "CWPAqrUT8Oq27OpnODYLP91KhNluYnMDDhDvGIoV"
  type        = string
}

variable "vpc_name" {
  default = "vpc-oracle-yyc"
}
variable "vpc_cidr" {
  default = "192.168.0.0/16"
}
variable "subnet_name" {
  default = "subent-oracle-1"
}
variable "subnet_cidr" {
  default = "192.168.1.0/24"
}
variable "subnet_gateway" {
  default = "192.168.1.1"
}
variable "primary_dns" {
  default = "100.125.1.250"
}

//子网2
variable "subnet2_name" {
  default = "subent-oracle-2"
}
variable "subnet2_cidr" {
  default = "192.168.64.0/18"
}
variable "subnet2_gateway" {
  default = "192.168.64.1"
}
variable "primary2_dns" {
  default = "100.125.1.250"
}

//安全组
variable "security_group" {
  default = "sg-oracle-yyc"
}

//ecs资源
variable "cpu" {
  default = 2
  type =  number
  description = "core"
}
variable "memory" {
  default = 4
  type =  number
  description = "GB"
}

variable "oracle_1_ip_1" {
  description = "ecs 1 ip 1"
  default     = "192.168.1.168"
  type        = string
}
variable "oracle_1_ip_2" {
  description = "ecs 1 ip 2"
  default     = "192.168.117.79"
  type        = string
}

variable "oracle_2_ip_1" {
  description = "ecs 1 ip 1"
  default     = "192.168.1.63"
  type        = string
}
variable "oracle_2_ip_2" {
  description = "ecs 1 ip 2"
  default     = "192.168.66.21"
  type        = string
}
//script
variable "db_name" {
  description = "The password of magento db name"
  default     = "magento_db2"
  type        = string
}


variable "password" {
  description = "ecs password"
  default     = "Aa!123456"
  type        = string
}
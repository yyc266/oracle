variable "region" {
  description = "region"
  default     = "cn-north-4"
  type        = string
}

variable "access_key" {
  description = "access_key"
  default     = ""
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  default     = ""
  type        = string
}

variable "vpc_name" {
  default = "vpc-basic"
}
variable "vpc_cidr" {
  default = "172.16.0.0/16"
}
variable "subnet_name" {
  default = "subent-basic"
}
variable "subnet_cidr" {
  default = "172.16.10.0/24"
}
variable "subnet_gateway" {
  default = "172.16.10.1"
}
variable "primary_dns" {
  default = "100.125.1.250"
}

variable "db_name" {
  description = "The password of magento db name"
  default     = "magento_db2"
  type        = string
}
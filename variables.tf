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

variable "template_name" {
  description = "The prefix name of the Huaweicloud service"
  default     = "demo-a"
  type        =  string
}

variable "password" {
  description = "root/oracle/grid password"
  default     = "Aa!123456"
  type        = string
}

variable "flavor_id" {
  description = "规格"
  default     = "c6.xlarge.2"
  type        = string
}
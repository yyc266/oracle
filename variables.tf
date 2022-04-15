variable "region" {
  description = "region"
  default     = "cn-north-4"
  type        = string
}

variable "creste_type" {
  default = 1
  type =  number
  description = "1:在新的vpc创建ecs；2：在已有vpc和subnet创建ecs；3：在已有vpc里创建新的subnet和ecs"
}

variable "vpc_name" {
  default = "vpc"
  type =  string
  description = "vpc 名字"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "subnet1_name" {
  default = "subent-oracle-1"
}

variable "subnet1_cidr" {
  default = "192.168.1.0/24"
}

variable "subnet1_gateway" {
  default = "192.168.1.1"
}

variable "subnet2_name" {
  default = "subent-oracle-2"
}

variable "subnet2_cidr" {
  default = "192.168.64.0/18"
}

variable "subnet2_gateway" {
  default = "192.168.64.1"
}

variable "oracle_version" {
  description = "oracle_version"
  default     = "11g"
  type        =  string
}

variable "template_name" {
  description = "The prefix name of the Huaweicloud service"
  default     = "demo"
  type        =  string
}

variable "password" {
  description = "root/oracle/grid password"
  default     = "Aa!123456"
  type        = string
}

variable "evs_ocr" {
  default = "ocr"
  type =  string
  description = "evs_ocr 名字"
}

variable "evs_data" {
  default = "data"
  type =  string
  description = "evs_data 名字"
}

variable "evs_flash" {
  default = "flash"
  type =  string
  description = "evs_flash 名字"
}

variable "evs_mgmt" {
  default = "mgmt"
  type =  string
  description = "evs_mgmt 名字"
}

variable "evs_ocr_size" {
  default = 10
  type =  number
  description = "evs_ocr 磁盘大小"
}

variable "evs_data_size" {
  default = 10
  type =  number
  description = "evs_data 磁盘大小"
}

variable "evs_flash_size" {
  default = 10
  type =  number
  description = "evs_flash 磁盘大小"
}

variable "evs_mgmt_size" {
  default = 10
  type =  number
  description = "evs_mgmt 磁盘大小"
}

variable "evs_mgmt_count" {
  default = 0
  type =  number
  description = "evs_mgmt 磁盘数量"
}

//ecs资源
variable "ecs_1" {
  default = "ecs_1"
  type =  string
  description = "ecs_1 名字"
}

variable "ecs_2" {
  default = "ecs_2"
  type =  string
  description = "ecs_2 名字"
}

variable "cpu" {
  default = 4
  type =  number
  description = "core"
}

variable "memory" {
  default = 8
  type =  number
  description = "GB"
}

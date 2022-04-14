variable "region" {
  description = "region"
  default     = "cn-north-4"
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

variable "vpc_name" {
  default = "vpc"
  type =  string
  description = "vpc 名字"
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
  default = "flush"
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

variable "evs_flush_size" {
  default = 10
  type =  number
  description = "evs_flush 磁盘大小"
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
variable "region" {
  description = "region"
  default     = "cn-north-4"
  type        = string
}

variable "access_key" {
  description = "access_key"
  default     = "please input"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  default     = "please input"
  type        = string
}

variable "vpc_name" {
  default = "vpc-oracle-b"
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
  default = "sg-oracle-a"
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


variable "password" {
  description = "ecs password"
  default     = "Aa!123456"
  type        = string
}

//vip
variable "scan_vip" {
  description = "scan_vip"
  default     = "192.168.1.241"
  type        = string
}

variable "vip_1" {
  description = "vip_1"
  default     = "192.168.1.242"
  type        = string
}
variable "vip_2" {
  description = "vip_2"
  default     = "192.168.1.243"
  type        = string
}
//kernel_shmall,kernel_shmax
variable "kernel_shmall" {
  description = "(单位B)计算公式为：kernel.shmax/4094，最小值为2097152"
  default     = "1073741824"
  type        = string
}
variable "kernel_shmax" {
  description = "要大于数据库的MEMORY_MAX_TARGET的值，推荐的计算公式为：机器内存总量（单位B）*60%"
  default     = "4398046511104"
  type        = string
}

variable "oracle_memlock" {
  description = "参数推荐的设置值为：机器的内存总量（KB）*90%"
  default     = "7549747"
  type        = string
}

//hostname
variable "oracle_1" {
  description = "ecs 1主机名"
  default     = "oracle-1"
  type        = string
}
variable "oracle_2" {
  description = "ecs 2主机名"
  default     = "oracle-2"
  type        = string
}

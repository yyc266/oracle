terraform {
  required_providers {
  huaweicloud = {
    source = "local-registry/huaweicloud/huaweicloud"
    version = "= 1.34.1"
    }
  random = {
    source = "local-registry/hashicorp/random"
    version = "= 3.1.0"
  }
  null = {
    source = "local-registry/hashicorp/null"
    version = "= 3.1.0"
  }
 template = {
    source = "local-registry/hashicorp/template"
    version = "= 2.2.0"
  }
 local = {
    source = "local-registry/hashicorp/local"
    version = "= 2.1.0"
  }
  }
 }
provider "huaweicloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
//配置网络
resource "huaweicloud_vpc" "vpc_1" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}
resource "huaweicloud_vpc_subnet" "subnet_1" {
  vpc_id      = huaweicloud_vpc.vpc_1.id
  name        = var.subnet_name
  cidr        = var.subnet_cidr
  gateway_ip  = var.subnet_gateway
  primary_dns = var.primary_dns
}

//创建两台ECS实例
data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}

resource "huaweicloud_compute_instance" "mycompute" {
  name              = "mycompute_${count.index}"
  image_id          = data.huaweicloud_images_image.myimage.id
  flavor_id         = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = ["default"]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  network {
    uuid = huaweicloud_vpc_subnet.subnet_1.id
  }
  count = 2
}

//申请虚拟IP地址并绑定ECS服务器对应的端口
resource "huaweicloud_networking_vip" "vip_1" {
  network_id = huaweicloud_vpc_subnet.subnet_1.id
}

# associate ports to the vip
resource "huaweicloud_networking_vip_associate" "vip_associated" {
  vip_id   = huaweicloud_networking_vip.vip_1.id
  port_ids = [
    huaweicloud_compute_instance.mycompute[0].network.0.port,
    huaweicloud_compute_instance.mycompute[1].network.0.port
  ]
}

 provider "huaweicloud" {
  region = "cn-north-4"
}

locals {
  vpc_create = var.creste_type == 1 ? 1 : 0
  subnet_create = var.creste_type == 1 || var.creste_type == 3 ? 1 : 0
}

//配置网络
resource "huaweicloud_vpc" "vpc_1" {
  count = local.vpc_create
  name = "${var.template_name}-${var.vpc_name}"
  cidr = var.vpc_cidr
}

data "huaweicloud_vpc" "vpc_1" {
  count =  local.vpc_create == 1 ? 0 : 1
  name = "${var.template_name}-${var.vpc_name}"
}

resource "huaweicloud_vpc_subnet" "subnet_1" {
  count = local.subnet_create
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.template_name}-${var.subnet1_name}"
  cidr        = var.subnet1_cidr
  gateway_ip  = var.subnet1_gateway
}

data "huaweicloud_vpc_subnet" "subnet_1" {
  count =  local.subnet_create == 1 ? 0 : 1
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.template_name}-${var.subnet1_name}"
  cidr        = var.subnet1_cidr
  gateway_ip  = var.subnet1_gateway
}

resource "huaweicloud_vpc_subnet" "subnet_2" {
  count = local.subnet_create
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.template_name}-${var.subnet2_name}"
  cidr        = var.subnet2_cidr
  gateway_ip  = var.subnet2_gateway
}

data "huaweicloud_vpc_subnet" "subnet_2" {
  count =  local.subnet_create == 1 ? 0 : 1
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.template_name}-${var.subnet2_name}"
  cidr        = var.subnet2_cidr
  gateway_ip  = var.subnet2_gateway
}

//安全组
resource "huaweicloud_networking_secgroup" "oracle_sg" {
  count = local.vpc_create
  name   = "${var.template_name}-secgroup"
}

data "huaweicloud_networking_secgroup" "oracle_sg" {
  count = local.vpc_create == 1 ? 0 : 1
  name   = "${var.template_name}-secgroup"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_1" {
  count = local.vpc_create
  security_group_id = huaweicloud_networking_secgroup.oracle_sg[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "5901-5910,3389"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_2" {
  count = local.vpc_create
  security_group_id = huaweicloud_networking_secgroup.oracle_sg[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          =  "tcp"
  remote_ip_prefix  = "169.254.0.0/16"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_3" {
  count = local.subnet_create
  security_group_id = local.vpc_create == 1 ?  huaweicloud_networking_secgroup.oracle_sg[0].id : data.huaweicloud_networking_secgroup.oracle_sg[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = var.subnet1_cidr
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_4" {
  count = local.subnet_create
  security_group_id = local.vpc_create == 1 ?  huaweicloud_networking_secgroup.oracle_sg[0].id : data.huaweicloud_networking_secgroup.oracle_sg[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = var.subnet2_cidr
}
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_5" {
  //count = local.subnet_create
  security_group_id = local.vpc_create == 1 ?  huaweicloud_networking_secgroup.oracle_sg[0].id : data.huaweicloud_networking_secgroup.oracle_sg[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22"
  remote_ip_prefix  = "0.0.0.0/0"
}

//创建两台ECS实例
data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_images_image" "centos7" {
  name        = "CentOS 7.6 64bit"
  most_recent = true
}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = var.cpu
  memory_size       = var.memory
}

resource "huaweicloud_compute_servergroup" "oracle_sg" {
  name     = "${var.template_name}-servergroup"
  policies = ["anti-affinity"]
}

resource "huaweicloud_compute_instance" "mycompute_1" {
  name              = "${var.template_name}-${var.ecs_1}"
  image_id          = data.huaweicloud_images_image.centos7.id
  flavor_id         =  data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = ["${var.template_name}-secgroup"]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  admin_pass        = var.password
  system_disk_size = 100
  scheduler_hints {
    group = huaweicloud_compute_servergroup.oracle_sg.id
  }
  network {
    uuid  = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
    //fixed_ip_v4  =   "192.168.1.168"
    source_dest_check  =  false
  }
  network {
    uuid  = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_2[0].id : data.huaweicloud_vpc_subnet.subnet_2[0].id
    //fixed_ip_v4  = "192.168.117.79"
    source_dest_check  =  false
  }
}

resource "huaweicloud_compute_instance" "mycompute_2" {
  name              = "${var.template_name}-${var.ecs_2}"
  image_id          = data.huaweicloud_images_image.centos7.id
  flavor_id         = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = ["${var.template_name}-secgroup"]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  admin_pass        = var.password
  system_disk_size = 100
  scheduler_hints {
    group = huaweicloud_compute_servergroup.oracle_sg.id
  }
  network {
    uuid  = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
    //fixed_ip_v4  =  "192.168.1.63"
    source_dest_check  =  false
  }
  network {
    uuid  = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_2[0].id : data.huaweicloud_vpc_subnet.subnet_2[0].id
    //fixed_ip_v4  =   "192.168.66.21"
    source_dest_check  =  false
  }

}

//EIP
resource "huaweicloud_vpc_bandwidth" "bandwidth_1" {
  name = "bandwidth_1"
  size = 5
}

resource "huaweicloud_vpc_eip" "myeip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type = "WHOLE"
    id         = huaweicloud_vpc_bandwidth.bandwidth_1.id
  }
  count  = 2
}

resource "huaweicloud_compute_eip_associate" "associated_1" {
  public_ip   = huaweicloud_vpc_eip.myeip[0].address
  instance_id = huaweicloud_compute_instance.mycompute_1.id
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.myeip[1].address
  instance_id = huaweicloud_compute_instance.mycompute_2.id
}

//申请虚拟IP地址并绑定ECS服务器对应的端口
resource "huaweicloud_networking_vip" "scan_vip" {
  network_id = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
  //ip_address = "192.168.1.241"
}

resource "huaweicloud_networking_vip" "vip_1" {
  network_id = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
  //ip_address = "192.168.1.242"
}

resource "huaweicloud_networking_vip" "vip_2" {
  network_id = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
  //ip_address = "192.168.1.243"
}

//网卡分配VIP
resource "huaweicloud_networking_vip_associate" "vip_associated_scan" {
  vip_id   = huaweicloud_networking_vip.scan_vip.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.0.port,
    huaweicloud_compute_instance.mycompute_2.network.0.port
  ]
}

resource "huaweicloud_networking_vip_associate" "vip_associated_vip_1" {
  vip_id   = huaweicloud_networking_vip.vip_1.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.0.port,
    huaweicloud_compute_instance.mycompute_2.network.0.port
  ]
}

resource "huaweicloud_networking_vip_associate" "vip_associated_vip_2" {
  vip_id   = huaweicloud_networking_vip.vip_2.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.0.port,
    huaweicloud_compute_instance.mycompute_2.network.0.port
  ]
}

//共享磁盘
resource "huaweicloud_evs_volume" "ocr" {
  name              = "${var.template_name}-${var.evs_ocr}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_ocr_size
  count             = 3
}

resource "huaweicloud_evs_volume" "mgmt" {
  name              = "${var.template_name}-${var.evs_mgmt}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_mgmt_size
  count             = var.evs_mgmt_count
}

resource "huaweicloud_evs_volume" "data" {
  name              = "${var.template_name}-${var.evs_data}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_data_size
  count             = 1
}

resource "huaweicloud_evs_volume" "flash" {
  name              = "${var.template_name}-${var.evs_flash}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_flash_size
  count             = 1
}

//user_data
data "template_file" "user_data" {
  //template = file("./user_data.sh")
  template = var.oracle_version == "19c" ? file("./user_data_19c.sh") : file("./user_data_11g.sh")

  vars = {
    PASSWORD  = var.password
    ORACLE_01 = "${var.template_name}-oracle-01"
    ORACLE_02 = "${var.template_name}-oracle-02"
    TEMPLATE_NAME = var.template_name
  }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.user_data.rendered}"
  filename = "./user1.sh"
}

//执行脚本
resource "null_resource" "provision_1" {
  depends_on = [huaweicloud_compute_eip_associate.associated,huaweicloud_compute_eip_associate.associated_1,local_file.save_inventory]
  count      = 2
  provisioner "file" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[count.index].address
    }
    source = "./user1.sh"
    destination = "/tmp/user1.sh"
  }
  provisioner "remote-exec" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[count.index].address
    }
    inline = [
      "sudo sh /tmp/user1.sh"
    ]
  }
}

resource "null_resource" "provision_2" {
  depends_on = [null_resource.provision_1]
  provisioner "local-exec" {
     //command = format("hcloud VPC DeleteSecurityGroupRule/v3   --cli-region=%s --security_group_rule_id=%s",var.region,huaweicloud_networking_secgroup_rule.secgroup_rule_5[0].id)
     command = format("hcloud VPC DeleteSecurityGroupRule/v3   --cli-region=%s --security_group_rule_id=%s",var.region,huaweicloud_networking_secgroup_rule.secgroup_rule_5.id)
  }
}
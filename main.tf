 provider "huaweicloud" {
  region = "cn-north-4"
}

locals {
  vpc_create = var.create_type == 1 ? 1 : 0
  subnet_create = var.create_type == 1 || var.create_type == 3 ? 1 : 0
}

//配置网络
resource "huaweicloud_vpc" "vpc_1" {
  count = local.vpc_create
  name = "${var.vpc_name}"
  cidr = var.vpc_cidr
}

data "huaweicloud_vpc" "vpc_1" {
  count =  local.vpc_create == 1 ? 0 : 1
  name = "${var.vpc_name}"
}

resource "huaweicloud_vpc_subnet" "subnet_1" {
  count = local.subnet_create
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.subnet1_name}"
  cidr        = var.subnet1_cidr
  gateway_ip  = var.subnet1_gateway
}

data "huaweicloud_vpc_subnet" "subnet_1" {
  count =  local.subnet_create == 1 ? 0 : 1
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.subnet1_name}"
  cidr        = var.subnet1_cidr
  gateway_ip  = var.subnet1_gateway
}

resource "huaweicloud_vpc_subnet" "subnet_2" {
  count = local.subnet_create
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.subnet2_name}"
  cidr        = var.subnet2_cidr
  gateway_ip  = var.subnet2_gateway
}

data "huaweicloud_vpc_subnet" "subnet_2" {
  count =  local.subnet_create == 1 ? 0 : 1
  vpc_id      = local.vpc_create == 1 ? huaweicloud_vpc.vpc_1[0].id : data.huaweicloud_vpc.vpc_1[0].id 
  name        = "${var.subnet2_name}"
  cidr        = var.subnet2_cidr
  gateway_ip  = var.subnet2_gateway
}

//安全组
resource "huaweicloud_networking_secgroup" "oracle_sg" {
  count = local.vpc_create
  name   = "secgroup"
}

data "huaweicloud_networking_secgroup" "oracle_sg" {
  count = local.vpc_create == 1 ? 0 : 1
  name   = "secgroup"
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
  name     = "servergroup"
  policies = ["anti-affinity"]
}

resource "huaweicloud_compute_instance" "mycompute" {
  count             = 2
  name              = count.index == 0 ? var.ecs_1 : var.ecs_2
  image_id          = data.huaweicloud_images_image.centos7.id
  flavor_id         =  data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = ["secgroup"]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  admin_pass        = var.password
  system_disk_size = 100
  scheduler_hints {
    group = huaweicloud_compute_servergroup.oracle_sg.id
  }
  network {
    uuid  = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
    source_dest_check  =  false
  }
}

//网卡
resource "huaweicloud_networking_port" "myport" {
  count          = 2
  name           = "port-${count.index}"
  network_id     = huaweicloud_vpc_subnet.subnet_2[0].id
  admin_state_up = "true"
  security_group_ids = [local.vpc_create == 1 ?  huaweicloud_networking_secgroup.oracle_sg[0].id : data.huaweicloud_networking_secgroup.oracle_sg[0].id]
}

resource "huaweicloud_compute_interface_attach" "attached" {
  count       = 2
  instance_id = huaweicloud_compute_instance.mycompute[count.index].id
  port_id     = huaweicloud_networking_port.myport[count.index].id
  source_dest_check  =  false
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

resource "huaweicloud_compute_eip_associate" "associated" {
  count       = 2
  public_ip   = huaweicloud_vpc_eip.myeip[count.index].address
  instance_id = huaweicloud_compute_instance.mycompute[count.index].id
}


//申请虚拟IP地址并绑定ECS服务器对应的端口
resource "huaweicloud_networking_vip" "vip" {
  count = 3
  network_id = local.subnet_create == 1 ?  huaweicloud_vpc_subnet.subnet_1[0].id : data.huaweicloud_vpc_subnet.subnet_1[0].id
}



//网卡分配VIP
resource "huaweicloud_networking_vip_associate" "vip_associated" {
  count    = 3
  vip_id   = huaweicloud_networking_vip.vip[count.index].id
  port_ids = [
    huaweicloud_compute_instance.mycompute[0].network.0.port,
    huaweicloud_compute_instance.mycompute[1].network.0.port
  ]
}


//共享磁盘
resource "huaweicloud_evs_volume" "ocr" {
  name              = "${var.evs_ocr}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_ocr_size
  count             = 3
}

resource "huaweicloud_evs_volume" "mgmt" {
  name              = "${var.evs_mgmt}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_mgmt_size
  count             = var.evs_mgmt_count
}

resource "huaweicloud_evs_volume" "data" {
  name              = "${var.evs_data}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_data_size
  count             = 1
}

resource "huaweicloud_evs_volume" "flash" {
  name              = "${var.evs_flash}-${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = var.evs_flash_size
  count             = 1
}

//user_data
data "template_file" "user_data" {
  depends_on = [huaweicloud_compute_interface_attach.attached,huaweicloud_networking_vip_associate.vip_associated]
  template = var.oracle_version == "19c" ? file("./user_data_19c.sh") : file("./user_data_11g.sh")

  vars = {
    PASSWORD  = var.password
    ORACLE_01 = var.ecs_1
    ORACLE_02 = var.ecs_2
    ORACLE_01_PUB_IP =  huaweicloud_compute_instance.mycompute[0].network.0.fixed_ip_v4
    ORACLE_01_PRI_IP =  huaweicloud_compute_instance.mycompute[0].network.1.fixed_ip_v4
    ORACLE_02_PUB_IP =  huaweicloud_compute_instance.mycompute[1].network.0.fixed_ip_v4
    ORACLE_02_PRI_IP =  huaweicloud_compute_instance.mycompute[1].network.1.fixed_ip_v4
    SCAN_VIP      = huaweicloud_networking_vip_associate.vip_associated[0].vip_ip_address
    ORACLE_01_VIP = huaweicloud_networking_vip_associate.vip_associated[1].vip_ip_address
    ORACLE_02_VIP = huaweicloud_networking_vip_associate.vip_associated[2].vip_ip_address

  }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.user_data.rendered}"
  filename = "./user1.sh"
}

//执行脚本
resource "null_resource" "provision_1" {
  depends_on = [huaweicloud_compute_eip_associate.associated,local_file.save_inventory]
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
     command = format("hcloud VPC DeleteSecurityGroupRule/v3   --cli-region=%s --security_group_rule_id=%s",var.region,huaweicloud_networking_secgroup_rule.secgroup_rule_5.id)
  }
}
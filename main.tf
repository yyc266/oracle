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

resource "huaweicloud_vpc_subnet" "subnet_2" {
  vpc_id      = huaweicloud_vpc.vpc_1.id
  name        = var.subnet2_name
  cidr        = var.subnet2_cidr
  gateway_ip  = var.subnet2_gateway
  primary_dns = var.primary2_dns
}

//安全组
# Create a Security Group
resource "huaweicloud_networking_secgroup" "oracle_sg" {
  name   = var.security_group
}



# Create a Security Group Rule 

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_1" {
  security_group_id = huaweicloud_networking_secgroup.oracle_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22,5901-5910,3389"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_2" {
  security_group_id = huaweicloud_networking_secgroup.oracle_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          =  "tcp"
  remote_ip_prefix  = "169.254.0.0/16"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_3" {
  security_group_id = huaweicloud_networking_secgroup.oracle_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.1.0/24"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_4" {
  security_group_id = huaweicloud_networking_secgroup.oracle_sg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.64.0/18"
}
//创建两台ECS实例
data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = var.cpu
  memory_size       = var.memory
}



resource "huaweicloud_compute_instance" "mycompute_1" {
  name              = "oracle_1"
  image_id          = "67f433d8-ed0e-4321-a8a2-a71838539e09"
  flavor_id         = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = [var.security_group]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  admin_pass        = var.password

  network {
    uuid  = huaweicloud_vpc_subnet.subnet_2.id
    fixed_ip_v4  =  var.oracle_1_ip_2
    source_dest_check  =  false
  }

  network {
    uuid  = huaweicloud_vpc_subnet.subnet_1.id
    fixed_ip_v4  =  var.oracle_1_ip_1
    source_dest_check  =  false

  }

}


resource "huaweicloud_compute_instance" "mycompute_2" {
  name              = "oracle_2"
  image_id          = "67f433d8-ed0e-4321-a8a2-a71838539e09"
  flavor_id         = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = [var.security_group]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[1]
  admin_pass        = var.password

  network {
    uuid  = huaweicloud_vpc_subnet.subnet_2.id
    fixed_ip_v4  =   var.oracle_2_ip_2
    source_dest_check  =  false
  }
    network {
    uuid  = huaweicloud_vpc_subnet.subnet_1.id
    fixed_ip_v4  =   var.oracle_2_ip_1
    source_dest_check  =  false
  }

}

//服务器组

resource "huaweicloud_compute_servergroup" "oracle-group" {
  name     = "oracle-group"
  policies = ["anti-affinity"]
  members  = [
    huaweicloud_compute_instance.mycompute_1.id,
    huaweicloud_compute_instance.mycompute_2.id,
  ]
}

//EIP
resource "huaweicloud_vpc_eip" "myeip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "mybandwidth"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
  count  = 2
}

resource "huaweicloud_compute_eip_associate" "associated_1" {
  public_ip   = huaweicloud_vpc_eip.myeip[0].address
  instance_id = huaweicloud_compute_instance.mycompute_1.id
  //fixed_ip    = huaweicloud_compute_instance.mycompute_1.network.1.fixed_ip_v4
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.myeip[1].address
  instance_id = huaweicloud_compute_instance.mycompute_2.id
  //fixed_ip    = huaweicloud_compute_instance.mycompute_2.network.1.fixed_ip_v4
}
//申请虚拟IP地址并绑定ECS服务器对应的端口
resource "huaweicloud_networking_vip" "scan_vip" {
  network_id = huaweicloud_vpc_subnet.subnet_1.id
  ip_address = var.scan_vip
}
resource "huaweicloud_networking_vip" "vip_1" {
  network_id = huaweicloud_vpc_subnet.subnet_1.id
  ip_address = var.vip_1
}
resource "huaweicloud_networking_vip" "vip_2" {
  network_id = huaweicloud_vpc_subnet.subnet_1.id
  ip_address = var.vip_2
}
# associate ports to the vip
resource "huaweicloud_networking_vip_associate" "vip_associated_scan" {
  vip_id   = huaweicloud_networking_vip.scan_vip.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.1.port,
    huaweicloud_compute_instance.mycompute_2.network.1.port
  ]
}
resource "huaweicloud_networking_vip_associate" "vip_associated_vip_1" {
  vip_id   = huaweicloud_networking_vip.vip_1.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.1.port,
    huaweicloud_compute_instance.mycompute_2.network.1.port
  ]
}
resource "huaweicloud_networking_vip_associate" "vip_associated_vip_2" {
  vip_id   = huaweicloud_networking_vip.vip_2.id
  port_ids = [
    huaweicloud_compute_instance.mycompute_1.network.1.port,
    huaweicloud_compute_instance.mycompute_2.network.1.port
  ]
}
//共享磁盘
resource "huaweicloud_evs_volume" "ocr" {
  name              = "oracle-10-000${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = 10
  count             = 3
}

resource "huaweicloud_evs_volume" "mgmt" {
  name              = "oracle-100-000${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = 100
  count             = 1
}

resource "huaweicloud_evs_volume" "data_flash" {
  name              = "oracle-1000-000${count.index}"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  device_type       = "SCSI"
  volume_type       = "SAS"
  multiattach       = true
  size              = 1000
  count             = 2
}

//user_data
data "template_file" "user_data" {
  template = "${file("user_data.sh")}"

  vars = {
    DB_NAME = var.db_name
  }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.user_data.rendered}"
  filename = "./user1.sh"
}

//执行脚本

resource "null_resource" "provision_1" {
  depends_on = []

  provisioner "file" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[0].address
    }
    source = "./user1.sh"
    destination = "/tmp/user1.sh"
  }
  provisioner "remote-exec" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[0].address
    }

    inline = [
      //format("sudo sh %s","${data.template_file.user_data.rendered}")
      "sudo sh /tmp/user1.sh"
    ]
  }
}

resource "null_resource" "provision_2" {
  depends_on = []

  provisioner "file" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[1].address
    }
    source = "./user1.sh"
    destination = "/tmp/user1.sh"
  }
  provisioner "remote-exec" {
    connection {
    type     = "ssh"
    user     = "root"
    password = var.password
    host        = huaweicloud_vpc_eip.myeip[1].address
    }

    inline = [
      //format("sudo sh %s","${data.template_file.user_data.rendered}")
      "sudo sh /tmp/user1.sh"
    ]
  }
}



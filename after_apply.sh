#!/bin/bash

yum -y install bc gcc gcc-c++  binutils  make gdb cmake  glibc ksh elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc-devel libaio libaio-devel libXrender libXrender-devel libX11 libXau sysstat libXi libXtst libgcc librdmacm-devel libstdc++ libstdc++-devel libxcb net-tools nfs-utils compat-libcap1 compat-libstdc++  smartmontools  targetcli python python-configshell python-rtslib python-six  unixODBC unixODBC-devel
yum groupinstall -y "X Window System"
yum groupinstall -y "GNOME Desktop"

yum install -y tigervnc-server
cat >> /etc/sysconfig/vncservers  << EOF
VNCSERVERS="2:root"
VNCSERVERARGS[2]="-geometry 1024x768 -nolisten tcp"
EOF

#systemctl stop avahi-daemon.service

reboot
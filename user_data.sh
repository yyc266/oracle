#!/bin/bash
#4.1
if  [ `hostname` == "${ORACLE_01}"  ]
    then
       echo "HOSTNAME=${ORACLE_01}"   >> /etc/sysconfig/network
    else
       echo "HOSTNAME=${ORACLE_02}"   >> /etc/sysconfig/network
fi
#4.2 hosts
cat >> /etc/hosts << EOF
#public ip 
192.168.1.168 ${ORACLE_01} 
192.168.1.63  ${ORACLE_02} 
 
#private ip 
192.168.117.79 ${ORACLE_01}-priv 
192.168.66.21  ${ORACLE_02}-priv 
 
#virtual ip 
192.168.1.242  ${ORACLE_02}-vip 
192.168.1.243  ${ORACLE_02}-vip 
 
#scan ip 
192.168.1.241  ${TEMPLATE_NAME}-orcl-scan 
EOF

#4.3
systemctl disable firewalld.service
systemctl stop firewalld.service
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
#4.4

#4.5
dd if=/dev/zero of=/home/swap bs=1G count=16
mkswap  /home/swap
swapon  /home/swap
cat >> /etc/fstab << EOF
/home/swap             swap          swap    defaults        0 0 
EOF

#4.6
cat > /etc/sysctl.conf  << EOF
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
EOF
sysctl -p
#4.7
cat >> /etc/security/limits.conf  << EOF
grid     soft    nproc   2047 
grid     hard    nproc   16384 
grid     soft    nofile  1024 
grid     hard    nofile  65536 
grid     soft    stack  10240 
grid     hard    stack  32768
oracle   soft    nproc   2047 
oracle   hard    nproc   16384 
oracle   soft    nofile  1024 
oracle   hard    nofile  65536 
oracle   soft    stack   10240
oracle   hard    stack   32768
oracle   soft    memlock 7549747
oracle   hard    memlock 7549747
EOF
#4.8
cat >> /etc/pam.d/login  << EOF
session    required     pam_limits.so
EOF

#4.9
groupadd -g 11001 oinstall
groupadd -g 11002 dba  
groupadd -g 11003 oper  
groupadd -g 11004 backupdba  
groupadd -g 11005 dgdba  
groupadd -g 11006 kmdba  
groupadd -g 11007 asmdba  
groupadd -g 11008 asmoper  
groupadd -g 11009 asmadmin  
groupadd -g 11010 racdba  
useradd -u 11011 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba,oper oracle  
useradd -u 11012 -g oinstall -G asmadmin,asmdba,asmoper,dba grid

mkdir -p /u01/app/oracle                                
chown -R oracle:oinstall /u01/app/oracle                
chmod -R 775 /u01/app/oracle
mkdir -p /u01/app/oracle/product/19.3.0/dbhome              
chown -R oracle:oinstall /u01/app/oracle/product/19.3.0/dbhome
chmod -R 775 /u01/app/oracle/product/19.3.0/dbhome

mkdir -p /u01/app/grid                                
chown -R oracle:oinstall /u01/app/grid               
chmod -R 775 /u01/app/grid
mkdir -p /u01/app/19.3.0/grid              
chown -R grid:oinstall /u01/app/19.3.0/grid
chmod -R 775 /u01/app/19.3.0/grid

mkdir -p /u01/app/oraInventory
chmod -R 775 /u01/app/oraInventory
chown -R grid:oinstall /u01/app/oraInventory

echo ${PASSWORD} | passwd grid --stdin > /dev/null 2>&1

echo ${PASSWORD} | passwd oracle --stdin > /dev/null 2>&1
#4.10
cat >> /etc/profile  << EOF
 if [ $USER = "oracle" ]; then 
   if [ $SHELL = "/bin/ksh" ]; then 
         ulimit -p 16384 
      ulimit -n 65536 
   else 
      ulimit -u 16384 -n 65536 
   fi 
fi
EOF
source /etc/profile
#
cat >> /home/grid/.bash_profile << EOF
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/19.3.0/grid
export NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"
export PATH=.:$PATH:$HOME/bin:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
if [ $USER = "oracle" ] || [ $USER = "grid" ]; then
        if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
        else
              ulimit -u 16384 -n 65536
        fi
        umask 022
fi
EOF
if  [ `hostname` == "${ORACLE_01}"  ]
    then
       echo "export ORACLE_SID=+ASM1"   >> /home/grid/.bash_profile
    else
       echo "export ORACLE_SID=+ASM2"   >> /home/grid/.bash_profile
fi
#
cat >> /home/oracle/.bash_profile << EOF
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/bin:/bin:/usr/bin:/usr/local/bin
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
if [ $USER = "oracle" ] || [ $USER = "grid" ]; then
        if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
        else
              ulimit -u 16384 -n 65536
        fi
        umask 022
fi
EOF
if  [ `hostname` == "${ORACLE_01}"  ]
    then
      echo "export ORACLE_SID=rac1"  >> /home/oracle/.bash_profile
    else
      echo "export ORACLE_SID=rac2"  >> /home/oracle/.bash_profile 
fi
#4.11
cat >> /etc/systemd/logind.conf  << EOF
RemoveIPC=no
EOF

# yum -y install bc gcc gcc-c++  binutils  make gdb cmake  \ 
#        glibc ksh elfutils-libelf elfutils-libelf-devel \
#        fontconfig-devel glibc-devel libaio libaio-devel \
#        libXrender libXrender-devel libX11 libXau sysstat \ 
#        libXi libXtst libgcc librdmacm-devel libstdc++ \
#        libstdc++-devel libxcb net-tools nfs-utils compat-libcap1 \
#        compat-libstdc++  smartmontools  targetcli python python-configshell \
#        python-rtslib python-six  unixODBC unixODBC-devel
# yum groupinstall -y "X Window System"
# yum groupinstall -y "GNOME Desktop"

# yum install -y tigervnc-server
# cat >> /etc/sysconfig/vncservers  << EOF
# VNCSERVERS="2:root"
# VNCSERVERARGS[2]="-geometry 1024x768 -nolisten tcp"
# EOF

#systemctl disable ntpd.service
#systemctl stop ntpd.service
#systemctl stop avahi-daemon.service

# #reboot


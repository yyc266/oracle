#!/bin/bash
#4.1
if  [ `hostname` == "${ORACLE_01}"  ]
    then
       echo "HOSTNAME=${ORACLE_01}"   >> /etc/sysconfig/network
    else
       echo "HOSTNAME=${ORACLE_02}"   >> /etc/sysconfig/network
fi
#4.2 hosts
cat > /etc/hosts << EOF
#public ip 
${ORACLE_01_PUB_IP}  ${ORACLE_01} 
${ORACLE_02_PUB_IP}   ${ORACLE_02} 
 
#private ip 
${ORACLE_01_PRI_IP}  ${ORACLE_01}-priv 
${ORACLE_02_PRI_IP}   ${ORACLE_02}-priv 
 
#virtual ip 
${ORACLE_01_VIP}   ${ORACLE_01}-vip 
${ORACLE_02_VIP}   ${ORACLE_02}-vip 
 
#scan ip 
${SCAN_VIP}  ${ORACLE_01}-${ORACLE_02}-orcl-scan 
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
groupadd -g 501 oinstall
groupadd -g 502 asmadmin  
groupadd -g 503 dba  
groupadd -g 504 oper 
groupadd -g 505 asmdba  
groupadd -g 506 asmoper  
 
useradd -u 501 -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid
useradd -u 502 -g oinstall -G dba,asmdba,oper oracle 

mkdir -p /u01/app/11.2.0/grid   
mkdir -p /u01/app/grid                             
chown -R grid:oinstall /u01 
mkdir -p /u01/app/oracle     
chown -R oracle:oinstall /u01/app/oracle 

chmod -R 775 /u01/
mkdir -p /u01/app/grid/oraInventory
chmod -R 775 /u01/app/grid/oraInventory
chown -R grid:oinstall /u01/app/grid/oraInventory

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
export ORACLE_HOME=/u01/app/11.2.0/grid
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/bin:/bin:/usr/bin/:/usr/local/bin:/usr/X11R6/bin/
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
umask 022
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
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_UNQNAME=rac
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/bin:/bin:/usr/bin/:/usr/local/bin:/usr/X11R6/bin/
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export TNS_ADMIN=$ORACLE_HOME/network/admin
export
umask 022
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

yum -y install binutils compat-libstdc++ compat-libcap1 gcc gcc-c++ \
               glibc glibc*.i686 glibc-devel glibc-devel*.i686 ksh libaio*.i686 libaio \
               libaio-devel*.i686 libaio-devel libgcc*.i686 libgcc libstdc++*.i686 libstdc++ \
               libstdc++-devel*.i686 libstdc++-devel libXi*.i686 libXi libXtst*.i686 libXtst \
               make sysstat unixODBC*.i686 unixODBC unixODBC-devel unzip

yum groupinstall -y "X Window System"
yum groupinstall -y "GNOME Desktop"

yum install -y tigervnc-server expect
#vnc
cp /usr/lib/systemd/system/vncserver@.service /usr/lib/systemd/system/vncserver@:1.service
sed -i 's/<USER>/root/g' /usr/lib/systemd/system/vncserver@:1.service
/usr/bin/expect <<EOF
spawn /usr/bin/vncpasswd
expect "Password:"
send "${PASSWORD}\r"
expect "Verify:"
send "${PASSWORD}\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
exit
EOF
systemctl daemon-reload
systemctl start vncserver@:1.service
systemctl enable vncserver@:1.service




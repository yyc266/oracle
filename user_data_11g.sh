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
192.168.1.168 ${ORACLE_01} 
192.168.1.63  ${ORACLE_02} 
 
#private ip 
192.168.117.79 ${ORACLE_01}-priv 
192.168.66.21  ${ORACLE_02}-priv 
 
#virtual ip 
192.168.1.242  ${ORACLE_02}-vip 
192.168.1.243  ${ORACLE_02}-vip 
 
#scan ip 
192.168.1.241  ${ORACLE_01}-${ORACLE_02}-orcl-scan 
EOF

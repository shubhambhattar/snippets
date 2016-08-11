#!/bin/sh

# This is used to create virtual interfaces on an existing interface.
# To know your existing interfaces, read below
# 

# Run command `ip addr`
#
# Below is a sample output:
#
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#      valid_lft forever preferred_lft forever
#    inet6 ::1/128 scope host
#      valid_lft forever preferred_lft forever
#2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
#    link/ether 00:0c:29:f5:d0:fe brd ff:ff:ff:ff:ff:ff
#    inet 20.10.151.91/8 brd 20.255.255.255 scope global ens160
#      valid_lft forever preferred_lft forever
#    inet6 fe80::20c:29ff:fef5:d0fe/64 scope link
#      valid_lft forever preferred_lft forever
#3: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
#    link/ether 00:0c:29:f5:d0:08 brd ff:ff:ff:ff:ff:ff
#    inet 20.10.199.10/8 brd 20.255.255.255 scope global ens192
#      valid_lft forever preferred_lft forever
#    inet6 fe80::20c:29ff:fef5:d008/64 scope link
#      valid_lft forever preferred_lft forever
#
#
# Here, ens160 & ens192 are my interface names.
# I can create virtual interfaces on above interfaces vis this script !!!



if [[ $# -eq 2 ]] || [[ $# -eq 3 && "$3" = "-f" ]]; then
	echo "$0  $@"
else
        echo "usage: $0 <iface_name> <new_bridge_name> <optional '-f' to force recreation>";
        exit 1;
fi

device=$1
linkname=$2

ifconfig $device 2>/dev/null
if [ $? -ne 0 ]; then
   echo "interface $device is not present";
   exit;
fi

ifconfig $linkname 2>/dev/null;
if [ $? -eq 0 ]; then
   if [ "$3" = "-f" ]; then
	ip link delete $linkname
	ifconfig $linkname 2>/dev/null;
	if [ $? -eq 0 ]; then
   		echo "bridge $linkname could not be deleted (even with force-delete option)";
		exit;
	fi
   	echo "bridge $linkname was deleted and recreated (-f option)";
   else
   	echo "bridge $linkname is already present";
   	echo "   call  '$0 $1 $2 -f'  to force override ";
	exit;
   fi
fi


ip link add $linkname link $device type macvlan mode bridge
ip link set dev $linkname up

#!/bin/bash

CADIR=/etc/openvpn-ca
OHOME=/etc/openvpn
MOUNTED_HOST_DIR=/out
HOST_IP=$HOST_IP
CONTAINER_NET_INTERFACE=eth0

mkdir -p $MOUNTED_HOST_DIR

cp $(find $CADIR -type f -name "client.key") $MOUNTED_HOST_DIR
cp $(find $CADIR -type f -name "client.crt") $MOUNTED_HOST_DIR
cp $(find $CADIR -type f -name "ca.crt") $MOUNTED_HOST_DIR
cp $(find $CADIR -type f -name "ta.key") $MOUNTED_HOST_DIR

sed -i -e "s/<0w0_SERVER_HOST>/$HOST_IP/g" $OHOME/client.example
cp $OHOME/client.example $MOUNTED_HOST_DIR/client.ovpn

# to solve the following error:
# ERROR: Cannot open TUN/TAP dev /dev/net/tun: No such file or directory (errno=2)
# https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/devices.txt
mkdir -p /dev/net && \
  mknod /dev/net/tun c 100 200 && \
  chmod 600 /dev/net/tun

iptables -t nat -C POSTROUTING -s 10.8.0.0/24 -o $CONTAINER_NET_INTERFACE -j MASQUERADE
openvpn --config $OHOME/server.conf

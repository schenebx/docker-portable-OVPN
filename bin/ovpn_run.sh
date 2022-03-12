#!/bin/bash

CADIR=/etc/openvpn-ca
OHOME=/etc/openvpn
MOUNTED_HOST_DIR=/out
HOST_IP=$HOST_IP
CONTAINER_NET_INTERFACE=eth0

TMPFS=$(mktemp -d)
mkdir -p $MOUNTED_HOST_DIR

cp $(find $CADIR -type f -name "client.key") $TMPFS
cp $(find $CADIR -type f -name "client.crt") $TMPFS
cp $(find $CADIR -type f -name "ca.crt") $TMPFS
cp $(find $CADIR -type f -name "ta.key") $TMPFS

rm -f $MOUNTED_HOST_DIR/conn.gz
tar cvfz $MOUNTED_HOST_DIR/conn.gz $TMPFS/*

sed -i -e "s/<0w0_SERVER_HOST>/$HOST_IP/g" $OHOME/client.example
cp $OHOME/client.example $MOUNTED_HOST_DIR/client.ovpn

iptables -t nat -C POSTROUTING -s 10.8.0.0/24 -o $CONTAINER_NET_INTERFACE -j MASQUERADE
openvpn --config $OHOME/server.conf

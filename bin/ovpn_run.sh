#!/bin/bash

# server global variable
HOST_IP=$HOST_IP

# defined in `server.conf`
OVPN_SUBNET=10.8.0.0/24

CADIR=/etc/openvpn-ca
OHOME=/etc/openvpn
MOUNTED_HOST_DIR=/out
CONTAINER_NET_INTERFACE=eth0

TMPFS=$(mktemp -d)
mkdir -p $MOUNTED_HOST_DIR

cp $(find $CADIR -type f -name "client.key") $TMPFS
cp $(find $CADIR -type f -name "client.crt") $TMPFS
cp $(find $CADIR -type f -name "ca.crt") $TMPFS
cp $(find $CADIR -type f -name "ta.key") $TMPFS
sed -i -e "s/<0w0_SERVER_HOST>/$HOST_IP/g" $OHOME/client.example
cp $OHOME/client.example $TMPFS/client.ovpn

rm -f $MOUNTED_HOST_DIR/conn.gz
tar cvfz $MOUNTED_HOST_DIR/conn.gz -C $TMPFS .

# Check if rule exist. Error if not exist. Add rule on error
iptables -t nat -C POSTROUTING -s $OVPN_SUBNET -o $CONTAINER_NET_INTERFACE -j MASQUERADE 2>/dev/null || {
    iptables -t nat -A POSTROUTING -s $OVPN_SUBNET -o $CONTAINER_NET_INTERFACE -j MASQUERADE
}
openvpn --config $OHOME/server.conf

#!/bin/bash

# server global variable
HOST_IP=$HOST_IP

[[ -z ${HOST_IP} ]] && read -p "Enter the public ip of this instance: " HOST_IP

mkdir -p $MOUNTED_HOST_DIR
rm -f $MOUNTED_HOST_DIR/*.gz

# defined in `server.conf`
OVPN_SUBNET=10.8.0.0/24

CADIR=/etc/openvpn-ca
OHOME=/etc/openvpn
MOUNTED_HOST_DIR=/out
CONTAINER_NET_INTERFACE=eth0

CA_FILE=$(find $CADIR -type f -name "ca.crt")
TA_FILE=$(find $CADIR -type f -name "ta.key")

for clientKeyABS in $(find $CADIR -type f -name "client*.key"); do
    clientName=$(basename $clientKeyABS | rev | cut -d "." -f 2- | rev)
    TMPFS=$(mktemp -d)
    cp $CA_FILE $TMPFS                          # ca.crt
    cp $TA_FILE $TMPFS                          # ta.key
    cp $(find $CADIR -type f -name "$clientName.key") $TMPFS # $clientName.key
    cp $(find $CADIR -type f -name "$clientName.crt") $TMPFS # $clientName.crt
    cp $OHOME/conf/client.example $TMPFS/$clientName.ovpn
    sed -i -e "s/<0w0_SERVER_HOST>/$HOST_IP/g" $TMPFS/$clientName.ovpn
    sed -i -e "s/<0w0_CLIENT_NAME>/$clientName/g" $TMPFS/$clientName.ovpn # $clientName.ovpn
    tar cvfz $MOUNTED_HOST_DIR/$clientName.gz -C $TMPFS .
done

# the 2FA imgs
cp $OHOME/2FA/*.png $MOUNTED_HOST_DIR

tar cvfz $MOUNTED_HOST_DIR/all.gz -C $MOUNTED_HOST_DIR .

# Check if rule exist. Error if not exist. Add rule on error
iptables -t nat -C POSTROUTING -s $OVPN_SUBNET -o $CONTAINER_NET_INTERFACE -j MASQUERADE 2>/dev/null || {
    iptables -t nat -A POSTROUTING -s $OVPN_SUBNET -o $CONTAINER_NET_INTERFACE -j MASQUERADE
}
openvpn --config $OHOME/conf/server.conf

CADIR=/etc/openvpn-ca
OHOME=/etc/openvpn
MOUNTED_HOST_DIR=/out
HOST_IP=$HOST_IP

# mkdir -p /out
cp $(find $CADIR -type f -name "client.key") $MOUNTED_HOST_DIR
cp $(find $CADIR -type f -name "client.crt") $MOUNTED_HOST_DIR
cp $(find $CADIR -type f -name "ca.crt") $MOUNTED_HOST_DIR

sed -i -e "s/<0w0_SERVER_HOST>/$HOST_IP/g" $OHOME/client.example
cp $OHOME/client.example $MOUNTED_HOST_DIR/client.ovpn

iptables -t nat -C POSTROUTING -s 10.8.0.0 -o $HOST_NET_INTERFACE -j MASQUERADE
openvpn --config /server.conf
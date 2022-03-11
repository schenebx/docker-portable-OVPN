iptables -t nat -C POSTROUTING -s 10.8.0.0 -o $HOST_NET_INTERFACE -j MASQUERADE
openvpn --config $PWD/../conf/server.conf"
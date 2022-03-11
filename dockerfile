# Original credit: https://github.com/jpetazzo/dockvpn
# Original credit: https://github.com/kylemanna/docker-openvpn

FROM ubuntu:focal
RUN apt update -y -q
RUN apt-get install -qy openvpn iptables curl easy-rsa
# RUN apt-get install -qy openvpn iptables curl bridge-utils
# RUN iptables -A INPUT -i tap0 -j ACCEPT
# RUN iptables -A INPUT -i br0 -j ACCEPT
# RUN iptables -A FORWARD -i br0 -j ACCEPT

ARG OHOME=/etc/openvpn
RUN mkdir -p $OHOME

RUN make-cadir /etc/openvpn-ca
WORKDIR /etc/openvpn-ca
RUN ./easyrsa init-pki
# CLI takes no options
RUN dd if=/dev/urandom of=pki/.rnd bs=256 count=1
RUN echo set_var EASYRSA_BATCH "1" | tee -a vars
RUN ./easyrsa build-ca nopass
RUN ./easyrsa build-server-full server nopass
RUN ./easyrsa build-client-full client nopass
RUN ./easyrsa gen-dh nopass

RUN cp $(find . -type f -name "ca.crt") $OHOME
RUN cp $(find . -type f -name "dh.pem") $OHOME
RUN cp $(find . -type f -name "server.key") $OHOME
RUN cp $(find . -type f -name "server.crt") $OHOME

# to the mounted volume
RUN mkdir -p out
RUN cp $(find . -type f -name "client.key") /out
RUN cp $(find . -type f -name "client.crt") /out
RUN cp $(find . -type f -name "ca.crt") /out

RUN sed -i -e "s/<0w0_SERVER_HOST>/$1/g" $OHOME/client.example
RUN TEMPDIR="$(mktemp -d)"; cp $OHOME/client.example $TEMPDIR && mv $TEMPDIR/client.example /out/client.ovpn

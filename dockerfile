# Original credit: https://github.com/jpetazzo/dockvpn
# Original credit: https://github.com/kylemanna/docker-openvpn

FROM ubuntu:focal
RUN apt update -y -q
RUN apt-get install -qy openvpn iptables curl easy-rsa iproute2

ARG OHOME=/etc/openvpn
ARG CADIR=/etc/openvpn-ca
RUN mkdir -p $OHOME

RUN make-cadir $CADIR
WORKDIR $CADIR
RUN ./easyrsa init-pki
# CLI takes no options
RUN dd if=/dev/urandom of=pki/.rnd bs=256 count=1
RUN echo set_var EASYRSA_BATCH "1" | tee -a vars
RUN ./easyrsa build-ca nopass
RUN ./easyrsa build-server-full server nopass
RUN ./easyrsa build-client-full client nopass
RUN ./easyrsa gen-dh nopass
RUN openvpn --genkey --secret $CADIR/ta.key

# SERVER keys are copied at build time
RUN cp $(find $CADIR -type f -name "ca.crt") $OHOME
RUN cp $(find $CADIR -type f -name "dh.pem") $OHOME
RUN cp $(find $CADIR -type f -name "server.key") $OHOME
RUN cp $(find $CADIR -type f -name "server.crt") $OHOME
RUN cp $(find $CADIR -type f -name "ta.key") $OHOME

# to solve the following error:
# ERROR: Cannot open TUN/TAP dev /dev/net/tun: No such file or directory (errno=2)
# https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/devices.txt
RUN mkdir -p /dev/net && \
    mknod /dev/net/tun c 100 200 && \
    chmod 600 /dev/net/tun

# server.conf && client.example
ADD ./conf $OHOME
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

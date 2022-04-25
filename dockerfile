FROM ubuntu:focal
RUN apt update -y -q
RUN apt-get install -qy openvpn iptables curl easy-rsa iproute2

ARG OHOME=/etc/openvpn
ARG CADIR=/etc/openvpn-ca
RUN mkdir -p $OHOME

RUN make-cadir $CADIR
WORKDIR $CADIR
RUN ./easyrsa init-pki
RUN dd if=/dev/urandom of=pki/.rnd bs=256 count=1
# run in batch mode, CLI takes no options
RUN echo set_var EASYRSA_BATCH "1" | tee -a vars
RUN ./easyrsa build-ca nopass
RUN ./easyrsa build-server-full server nopass
RUN ./easyrsa gen-dh
RUN openvpn --genkey --secret $CADIR/ta.key

# SERVER keys are copied at build time
RUN cp $(find $CADIR -type f -name "ca.crt") $OHOME
RUN cp $(find $CADIR -type f -name "dh.pem") $OHOME
RUN cp $(find $CADIR -type f -name "server.key") $OHOME
RUN cp $(find $CADIR -type f -name "server.crt") $OHOME
RUN cp $(find $CADIR -type f -name "ta.key") $OHOME

RUN ./easyrsa build-client-full client0 nopass
RUN ./easyrsa build-client-full client1 nopass
RUN ./easyrsa build-client-full client2 nopass
RUN ./easyrsa build-client-full client3 nopass
RUN ./easyrsa build-client-full client4 nopass
RUN ./easyrsa build-client-full client5 nopass
RUN ./easyrsa build-client-full client6 nopass
RUN ./easyrsa build-client-full client7 nopass
RUN ./easyrsa build-client-full client8 nopass
RUN ./easyrsa build-client-full client9 nopass
RUN ./easyrsa build-client-full client10 nopass

# This param may not be writable on some VM platform (e.g. Azure) and thus has no effect.
# Change the `ip_forward` option in the VM Service Provider's console if necessary.
RUN sysctl -w net.ipv4.ip_forward=1

## server.conf && client.example
# ADD ./conf $OHOME
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

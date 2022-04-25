FROM ubuntu:focal
RUN apt update -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN apt-get install -q -y openvpn iptables curl easy-rsa iproute2 oathtool python3 python3-pip nodejs
RUN pip3 install -y pillow qrcode

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
RUN ./easyrsa build-client-full client11 nopass
RUN ./easyrsa build-client-full client12 nopass

# RUN DIGEST=$(LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 40 | sha256sum | cut -d ' ' -f 1) && \
RUN mkdir -p $OHOME/2FA
WORKDIR $OHOME/2FA
ADD ./plugins .
RUN chmod +x *.sh *.py
RUN oauthSecrets=$OHOME/2FA/oauth.secrets && echo > $oauthSecrets && ./2FA_gen_secrets.sh 12 $oauthSecrets && ./2FA_secret_to_img.sh $oauthSecrets

# This param may not be writable on some VM platform (e.g. Azure) and thus has no effect.
# Change the `ip_forward` option in the VM Service Provider's console if necessary.
RUN sysctl -w net.ipv4.ip_forward=1

## server.conf && client.example
# ADD ./conf $OHOME
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

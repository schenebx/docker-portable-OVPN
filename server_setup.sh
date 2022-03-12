#!/bin/bash

sleep 5s

PKG_LISTS="docker docker-compose git vim tmux iptables iproute2 p7zip-full"
apt update -y && apt upgrade -y && apt-get install -y $PKG_LISTS

echo VISUAL=vim | tee -a ~/.bashrc
echo EDITOR=vim | tee -a ~/.bashrc

cat <<'EOF' > /root/.vimrc
colorscheme desert
EOF

chmod 644 /root/.vimrc

SWAP_ON_SCRIPT="/root/server_setup_swap.sh"
cat <<'EOF' > $SWAP_ON_SCRIPT
#!/bin/bash

fallocate -l 5G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo 'swap is on'
free -h

EOF

chmod u+x $SWAP_ON_SCRIPT && bash $SWAP_ON_SCRIPT

# VOLATILE
cat << 'EOF' >> ~/.bashrc
export HOST_NET_INTERFACE=enp1s0

HOST_IP=$(ip addr | grep $HOST_NET_INTERFACE | grep inet | awk -F " brd" '{print $1}' | awk -F "inet " '{print $2}' | cut -d '/' -f 1)
export HOST_IP=$HOST_IP

cd /srv/docker-portable-OVPN
EOF

# Allowing Incoming HTTP && HTTPS
iptables -C INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 2>/dev/null || {
    iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
}
iptables -C OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT 2>/dev/null || {
    iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
}

# OPENVPN SETUP
mkdir -p /out

# if dir not exist, then init
D0=/srv/docker-portable-OVPN
[[ -d $D0 ]] || git clone https://github.com/schen0x/docker-portable-OVPN $D0

# VOLATILE
HOST_NET_INTERFACE=enp1s0
export HOST_IP=$(ip addr | grep $HOST_NET_INTERFACE | grep inet | awk -F " brd" '{print $1}' | awk -F "inet " '{print $2}' | cut -d '/' -f 1)

# refresh the ENVs
bash && cd $D0

docker-compose build && docker-compose up -d

#!/bin/bash

# as root

sleep 5s

PKG_LISTS="docker docker-compose git vim tmux iptables iproute2 p7zip-full zip"
apt update -y && apt upgrade -y && apt-get install -y $PKG_LISTS

echo VISUAL=vim | tee -a $HOME/.bashrc
echo EDITOR=vim | tee -a $HOME/.bashrc

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

# OPENVPN SETUP
mkdir -p /out

# # if dir not exist, then init
D0=/srv/docker-portable-OVPN
[[ -d $D0 ]] || git clone https://github.com/schenebx/docker-portable-OVPN $D0
# 
# # Allowing SSH
# iptables -C INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 2>/dev/null || {
#     iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#     iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
# }
# 
# # Allowing Incoming HTTP && HTTPS
# iptables -C INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 2>/dev/null || {
#     iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# }
# iptables -C OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT 2>/dev/null || {
#     iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
# }
# 
# # Allowing OVPN connection
# iptables -C INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT 2>/dev/null || {
#     iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
# }


echo VISUAL=vim | tee -a $HOME/.bashrc
echo EDITOR=vim | tee -a $HOME/.bashrc

# still as root, since we run docker as root which use the ENVs of root.
# VOLATILE
cat << 'EOF' >> ~/.bashrc
export HOST_NET_INTERFACE=eth0
export HOST_IP=<insert_host_ip>

# HOST_IP=$(ip addr | grep $HOST_NET_INTERFACE | grep inet | awk -F " brd" '{print $1}' | awk -F "inet " '{print $2}' | cut -d '/' -f 1)
# export HOST_IP=$HOST_IP

cd /srv/docker-portable-OVPN
EOF

# VOLATILE
HOST_NET_INTERFACE=eth0
# export HOST_IP=$(ip addr | grep $HOST_NET_INTERFACE | grep inet | awk -F " brd" '{print $1}' | awk -F "inet " '{print $2}' | cut -d '/' -f 1)
export HOST_IP=<insert_host_ip>

cd $D0
# docker-compose build && docker-compose up -d
[[ ! -z $HOST_IP ]] && { echo "HOST_IP=$HOST_IP, setting up ovpn docker in the background, check the progress with `docker-compose logs`" && docker-compose build && docker-compose up -d
} || echo "WARN: HOST_IP is not set!"

#!/bin/sh

sleep 5s

PKG_LISTS="docker docker-compose git vim tmux nmap sshuttle proxychains openvpn gobuster ffuf p7zip-full"
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

# volatile
interface=enp1s0
HOST_IP=$(ip addr | grep $interface | grep inet | awk -F " brd" '{print $1}' | awk -F "inet " '{print $2}' | cut -d '/' -f 1)

echo HOST_IP=$HOST_IP | tee -a /etc/environment

# OPENVPN SETUP
mkdir -p /srv/openvpn
mkdir -p /out
#!/bin/bash

#çıktıları azaltır
export DEBIAN_FRONTEND=noninteractive

#apt repolarını ekler
cat > /etc/apt/source.list << EOF
deb https://deb.debian.org/debian bookworm contrib main non-free non-free-firmware
deb-src htttps://deb.debian.org/debian bookworm contrib main non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-updates contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-updates contrib main non-free non-free-firmware
deb https://security.debian.org/debian-security bookworm-security contrib main non-free non-free-firmware
deb-src https://security.debian.org/debian-security bookworm-security contrib main non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-backports main non-free contrib
deb-src https://deb.debian.org/debian bookworm-backports main non-free contrib
EOF

#gerekli paketleri indirir
apt update
apt -y upgrade
#firmware paketlerini indirir
apt -y install $(apt search ^firmware- 2> /dev/null | grep ^firmware | grep -v micropython-dl | cut -d "/" -f 1)
#Linux GUİ paketleri
apt -y install i3 xtrlock thunar zsh
#Terminal odaklı paketler
apt -y install vim tmux openssh-server htop
apt -y install feathernotes atrill pavucontroll unzip xfce4-terminal freerdp2-x11 vlc
apt -y install firefox-esr chromium
apt -y install libreoffice-writer libreoffice-calc
apt -y install git
apt -y install ack wget curl rsync dnsutils whois net-tools
apt -y install gnupg openvpn
apt -y install encfs ntfs-3g
apt -y install python-pip
apt -y install python3 bpython3
apt -y install python3-pip --install-recommends
apt -y install software-properties-common
apt -y install lsb-release apt-transport-https

# Virtualbox install
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | gpg --dearmor -o /usr/share/keyrings/virtualbox.gpg
echo "deb [signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" >> /etc/apt/sources.list

apt update
apt -y install virtualbox-7.1

# Install LXC and create a Virtual Network
apt -y install --install-recommends lxc debootstrap bridge-utils

# Network1 and Bridge1 Virtual Network Configured
cat > /etc/network/interfaces.d/bridge1.cfg << EOF
auto network1
iface network1 inet manual
address 10.1.1.1
netmask 255.255.255.0
bridge_ports bridge1
bridge_stp off
bridge_fd 0
bridge_maxwait 0
EOF

ip a
brctl show
ifup network1
ifup bridge1

sleep 2

#Create Template Container (Debian Stable)
#lxc-create -n template-bookworm -t download -P /var/lib/lxc -- -d debian -r bookworm -a amd64
lxc-create -n template-bookworm -t debian -- -r bookworm

cat > /var/lib/lxc/template-bookworm/config << EOF
# Common configuration
lxc.include = /usr/share/lxc/config/debian.common.conf
lxc.arch = amd64
lxc.apparmor.profile = unconfined
#KONTROL
lxc.apparmor.allow_nesting = 1
lxc.uts.name = template-bookworm2
lxc.rootfs.path = dir:/var/lib/lxc/template-bookworm2/rootfs

#Container specific configuration
lxc.include = /usr/share/lxc/config/nesting.conf

#Network Configuration
lxc.net.0.type = veth
lxc.net.0.link = bridge1
lxc.net.0.name = eth0
lxc.net.0.flags = up
EOF

# Set static ip to tempate-bookworm container
# vim /var/lib/lxc/template-bookworm/rootfs/etc/network/interfaces
#


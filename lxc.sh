#!/bin/bash

# LXC Otomasyon Kurulum Scripti

# Süper kullanıcı kontrolü
if [ "$EUID" -ne 0 ]; then
    echo "Bu scripti çalıştırmak için root haklarına sahip olmalısınız."
    exit 1
fi

# Sistem güncellemeleri
echo "[1/5] Sistemi güncelliyorum..."
apt update && apt upgrade -y

# Gerekli bağımlılıkları yükleme
echo "[2/5] Gerekli bağımlılıkları yüklüyorum..."
apt install -y lxc lxc-templates lxc-utils uidmap bridge-utils debootstrap curl

# Kernel modüllerini yükleme
echo "[3/5] Gerekli kernel modüllerini yükleyip etkinleştiriyorum..."
modprobe overlay
modprobe br_netfilter

# Modülleri kalıcı hale getirme
echo "overlay\nbr_netfilter" >> /etc/modules

# LXC ağ ayarları yapılandırma
echo "[4/5] LXC ağ ayarlarını yapılandırıyorum..."
cat << EOF > /etc/lxc/default.conf
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
EOF

cat << EOF > /etc/network/interfaces.d/lxcbr0
auto lxcbr0
iface lxcbr0 inet static
    address 10.0.3.1
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0
EOF

# Ağ servisini yeniden başlatma
systemctl restart networking

# LXC kontrol ve doğrulama
echo "[5/5] LXC kurulumunu ve yapılandırmasını kontrol ediyorum..."
if command -v lxc-checkconfig &> /dev/null; then
    lxc-checkconfig
    echo "LXC başarıyla kuruldu ve yapılandırıldı."
else
    echo "LXC kurulumu sırasında bir sorun oluştu."
fi


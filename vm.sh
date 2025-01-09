#!/bin/bash

# VirtualBox Otomasyon Kurulum Scripti

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
apt install -y dkms build-essential linux-headers-$(uname -r) curl gnupg

# VirtualBox GPG anahtarını ekleme
echo "[3/5] VirtualBox için GPG anahtarını ekliyorum..."
GPG_KEY_URL="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
curl -fsSL $GPG_KEY_URL | gpg --dearmor -o /usr/share/keyrings/virtualbox.gpg

# VirtualBox deposunu ekleme
echo "[4/5] VirtualBox deposunu ekliyorum..."
echo "deb [signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" > /etc/apt/sources.list.d/virtualbox.list

# Paket listesi güncelleme ve VirtualBox kurulumu
echo "[5/5] Paket listesini güncelliyor ve VirtualBox'ı yüklüyorum..."
apt update
apt install -y virtualbox-7.0

# Kurulum doğrulama
if command -v vboxmanage &> /dev/null; then
    echo "VirtualBox başarıyla kuruldu."
else
    echo "VirtualBox kurulumu sırasında bir sorun oluştu."
fi


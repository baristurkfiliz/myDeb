#!/bin/bash
#
# Tüm donanımı tarayıp uygun Debian firmware veya sürücü paketlerini yükleyen script

echo "=== Donanım Taraması ve Firmware Yükleyici ==="
echo "Sistemdeki tüm donanım taranıyor..."

# Donanım bilgilerini toplama
pci_devices=$(lspci)
usb_devices=$(lsusb)

# Donanım bilgilerini yazdır
echo -e "\n[PCI Cihazları]"
echo "$pci_devices"
echo -e "\n[USB Cihazları]"
echo "$usb_devices"

# Uygun paketleri yükleyecek bir işlev
install_firmware_for_device() {
    local device="$1"
    echo -e "\n[Aranıyor]: $device"

    # Donanıma uygun paketleri bulma
    apt_packages=$(apt-cache search firmware | grep -i "$(echo $device | awk '{print $1}')" | awk '{print $1}')

    if [ -n "$apt_packages" ]; then
        echo -e "\n[Bulunan Paketler]:"
        echo "$apt_packages"

        echo -e "\n[Kurulum Başlıyor...]"
        sudo apt install -y $apt_packages
    else
        echo "[Uygun Paket Bulunamadı]: $device"
    fi
}

# PCI cihazları için firmware taraması
echo -e "\n=== PCI Cihazları İçin Firmware Aranıyor ==="
echo "$pci_devices" | while read -r device; do
    install_firmware_for_device "$device"
done

# USB cihazları için firmware taraması
echo -e "\n=== USB Cihazları İçin Firmware Aranıyor ==="
echo "$usb_devices" | while read -r device; do
    install_firmware_for_device "$device"
done

echo -e "\n=== İşlem Tamamlandı ==="


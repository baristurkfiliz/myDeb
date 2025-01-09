#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive

# GUI - Başlangıç değişkenleri
processed=0
success=0
failed=0
total_packages=0
firmware_packages=()
pci_packages=()
usb_packages=()
apt_output=()
footer_output=()

# GUI - Üst bilgi satırlarını günceller (Header)
update_header() {
    tput cup 0 0
    printf "\033[1;34mToplam: %d/%d (Başarılı: %d | Hatalı: %d)\033[0m\n" \
        "$processed" "$total_packages" "$success" "$failed"
    tput el
}

# GUI - Middle bölümünde apt çıktısını günceller
update_middle() {
    local message="$1"
    apt_output+=("$message")
    if ((${#apt_output[@]} > 5)); then
        apt_output=("${apt_output[@]:1}")
    fi

    tput cup 2 0
    for line in "${apt_output[@]}"; do
        printf "\033[0m%-80s\n" "$line"
    done

    for _ in $(seq ${#apt_output[@]} 5); do
        printf "%-80s\n" " "
    done
}

# GUI - Middle'ı yüklemeden sonra temizleyen fonksiyon
clear_middle() {
    tput cup 2 0
    for _ in $(seq 1 5); do
        printf "%-80s\n" " "
    done
}

# GUI - Footer bölümünde yükleme sonuçlarını günceller
update_footer() {
    local message="$1"
    footer_output=("$message" "${footer_output[@]}")
    tput cup 8 0
    for line in "${footer_output[@]}"; do
        printf "\033[0m%-80s\n" "$line"
    done
}

# GUI - Programın bitişi için header'ı son duruma göre günceller ve middle'ı temizler
finalize_footer() {
    clear_middle

    tput cup 0 0
    printf "\033[1;34mToplam: %d/%d (Başarılı: %d | Hatalı: %d)\033[0m\n" \
        "$processed" "$total_packages" "$success" "$failed"

    tput cup 8 0
    for line in "${footer_output[@]}"; do
        printf "\033[0m%-80s\n" "$line"
    done
}

# GUI - Terminali temizle ve gizle
clear
tput civis
trap "tput cnorm; exit" INT TERM EXIT

# Apt kaynak listesini güncelle
update_middle "Kütüphaneler ekleniyor..."
cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian bookworm contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm contrib main non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-updates contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-updates contrib main non-free non-free-firmware
deb https://deb.debian.org/debian-security bookworm-security contrib main non-free non-free-firmware
deb-src https://deb.debian.org/debian-security bookworm-security contrib main non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-backports main non-free contrib
deb-src https://deb.debian.org/debian bookworm-backports main non-free contrib
EOF

# Sistemi güncelle
apt update -y -q
apt full-upgrade -y -q

# Apt paketleri
apt_packages=(
    "i3 xtrlock thunar zsh"
    "xinit xserver-xorg x11-utils"
    "xserver-xorg-video-all xserver-xorg-input-all"
    "fonts-noto fonts-dejavu fonts-liberation lxappearance"
    "network-manager"
    "bluetooth bluez blueman"
    "vim tmux openssh-server htop iftop"
    "feathernotes atril pavucontrol unzip xfce4-terminal freerdp2-x11 vlc"
    "firefox-esr chromium tor"
    "libreoffice-writer libreoffice-calc"
    "git"
    "ack wget curl rsync dnsutils whois net-tools"
    "gnupg openvpn"
    "encfs ntfs-3g"
    "python-pip"
    "python3 bpython3"
    "python3-pip --install-recommends"
    "software-properties-common"
    "lsb-release apt-transport-https"
)

# Firmware ve donanım paketlerini ara ve listele
update_middle "Firmware ve donanım paketleri hazırlanıyor..."
firmware_packages=($(apt-cache search ^firmware- | awk '{print $1}' | grep -v micropython-dl))
while read -r device; do
    pci_packages+=($(apt-cache search firmware | grep -i "$(echo $device | awk '{print $1}')" | awk '{print $1}'))
done < <(lspci)
while read -r device; do
    usb_packages+=($(apt-cache search firmware | grep -i "$(echo $device | awk '{print $1}')" | awk '{print $1}'))
done < <(lsusb)

# Toplam paket sayısını hesapla
expanded_packages=()
for group in "${apt_packages[@]}"; do
    for package in $group; do
        expanded_packages+=("$package")
    done
done
total_packages=$((total_packages + ${#firmware_packages[@]} + ${#pci_packages[@]} + ${#usb_packages[@]} + ${#expanded_packages[@]}))

# Firmware paketlerini yükle
for package in "${firmware_packages[@]}"; do
    update_header
    update_middle "Firmware paketi yükleniyor: $package"
    if apt install -y -q "$package" >/dev/null 2>&1; then
        update_footer "Başarıyla yüklendi: $package"
        ((success++))
    else
        update_footer "Hata oluştu: $package"
        ((failed++))
    fi
    ((processed++))
done

# PCI donanım paketlerini yükle
for package in "${pci_packages[@]}"; do
    update_header
    update_middle "PCI paketi yükleniyor: $package"
    if apt install -y -q "$package" >/dev/null 2>&1; then
        update_footer "Başarıyla yüklendi: $package"
        ((success++))
    else
        update_footer "Hata oluştu: $package"
        ((failed++))
    fi
    ((processed++))
done

# USB donanım paketlerini yükle
for package in "${usb_packages[@]}"; do
    update_header
    update_middle "USB paketi yükleniyor: $package"
    if apt install -y -q "$package" >/dev/null 2>&1; then
        update_footer "Başarıyla yüklendi: $package"
        ((success++))
    else
        update_footer "Hata oluştu: $package"
        ((failed++))
    fi
    ((processed++))
done

# Uygulama paketlerini yükle
for package in "${expanded_packages[@]}"; do
    update_header
    update_middle "Paket yükleniyor: $package"
    if apt install -y -q "$package" >/dev/null 2>&1; then
        update_footer "Başarıyla yüklendi: $package"
        ((success++))
    else
        update_footer "Hata oluştu: $package"
        ((failed++))
    fi
    ((processed++))
done

# Log dosyasını yaz
{
    echo "Başarıyla tamamlanan paketler:"
    printf "%s\n" "${footer_output[@]}"
} >apt-install.log

# Footer'ı sabit hale getir ve middle'ı temizle
finalize_footer
tput cnorm # İmleci geri getir


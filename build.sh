#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

sudo rm -rf config cache chroot .build binary images
mkdir -p images

# Configuração base
lb config noauto \
    --distribution bookworm \
    --architecture amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer live \
    --iso-volume "Carlinho-Linux" \
    --iso-application "Carlinho-Linux" \
    --bootappend-live "boot=live components locales=pt_BR.UTF-8 keyboard-layouts=br hostname=carlinho username=carlinho" \
    --image-name carlinho-linux

# Copiar package list
mkdir -p config/package-lists
cat > config/package-lists/carlinho.list.chroot << 'EOF'
# ===== Ambiente de Desktop =====
xfce4
xfce4-terminal
xfce4-goodies
lightdm
network-manager-gnome
pulseaudio
pavucontrol

# Navegador
firefox-esr

# Desenvolvimento 
code
git
build-essential
python3
python3-pip
curl
wget

# Utilitários 
mousepad
gnome-text-editor
file-roller
thunar
gpicview
rhythmbox

# Câmera / Galeria 
cheese
gthumb

# Sistema 
gparted
htop
neofetch
fonts-dejavu
fonts-noto-color-emoji
locales
EOF

# Gerar ISO
sudo lb build 2>&1 | tee build.log

mv carlinho-linux*.iso images/ 2>/dev/null || true
echo "✅ ISO gerada em images/"

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
    --bootappend-live "boot=live components locales=pt_BR.UTF-8 keyboard-layouts=br hostname=carlinho username=carlinho"

# Copiar package list 
mkdir -p config/package-lists
cat > config/package-lists/carlinho.list.chroot << 'EOF'
# Ambiente de Desktop 
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

# Baixar o VSCode
mkdir -p config/packages.chroot
wget -q -O config/packages.chroot/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

# Gerar a ISO
sudo lb build 2>&1 | tee build.log

# Renomear qualquer ISO gerada
sudo find . -maxdepth 1 -name "*.iso" -exec mv {} images/Carlinho-Linux-amd64.iso \;
echo "ISO gerada em images/"

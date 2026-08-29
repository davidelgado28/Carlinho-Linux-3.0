#!/bin/bash
set -e

for cmd in lb debootstrap xorriso; do
    if ! which "$cmd" > /dev/null 2>&1; then
        echo "❌ Comando '$cmd' não encontrado!"
        exit 1
    fi
done

# Limpeza
sudo rm -rf cache chroot .build binary build.log

# Configuração
lb config noauto \
    --mode debian \
    --distribution bookworm \
    --architecture amd64 \
    --mirror-bootstrap "http://deb.debian.org/debian" \
    --mirror-binary "http://deb.debian.org/debian" \
    --mirror-binary-security "http://security.debian.org/debian-security" \
    --debian-installer live \
    --bootappend-live "boot=live components locales=pt_BR.UTF-8 keyboard-layouts=br hostname=carlinho username=carlinho"

sed -i 's|bookworm/updates|bookworm-security|g' config/chroot || true
sed -i 's|http://security.debian.org$|http://security.debian.org/debian-security|g' config/chroot || true
sed -i 's|http://security.debian.org/$|http://security.debian.org/debian-security|g' config/chroot || true

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

# Gerar ISO
sudo lb build 2>&1 | tee build.log

if ! ls *.iso binary*.iso 2>/dev/null | grep -q iso; then
    echo "❌ O lb build FALHOU."
    echo "🔍 Linhas com erro:"
    grep -iE "^E:|error|failed|Fatal" build.log | tail -30 || true
    echo "🔍 Últimas 40 linhas:"
    tail -40 build.log
    exit 1
fi
mkdir -p images
mv *.iso images/Carlinho-Linux-amd64.iso
echo "ISO gerada em images/"

# Renomear qualquer ISO gerada
sudo find . -maxdepth 1 -name "*.iso" -exec mv {} images/Carlinho-Linux-amd64.iso \;
echo "ISO gerada em images/"

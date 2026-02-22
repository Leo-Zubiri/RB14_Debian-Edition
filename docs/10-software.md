# 10 — Software

## Estado: Pendiente

---

## Objetivos

- Paquetes esenciales del sistema
- Configurar Flatpak con Flathub
- Herramientas de desarrollo
- Aplicaciones cotidianas

---

## 1. Paquetes del sistema

```bash
sudo apt install -y \
  git curl wget vim htop tree \
  build-essential cmake pkg-config \
  dkms linux-headers-$(uname -r) \
  apt-transport-https ca-certificates gnupg \
  lsb-release \
  unzip p7zip-full \
  net-tools nmap traceroute \
  rsync \
  bash-completion \
  jq \
  tmux \
  fd-find bat ripgrep fzf \
  tldr
```

---

## 2. Flatpak + Flathub

```bash
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Reboot para que el repositorio quede disponible en GNOME Software.

Verificar:

```bash
flatpak remotes
flatpak list
```

---

## 3. Aplicaciones cotidianas (Flatpak)

```bash
# Navegadores
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.brave.Browser

# Comunicacion
flatpak install flathub org.signal.Signal
flatpak install flathub com.slack.Slack

# Multimedia
flatpak install flathub org.videolan.VLC
flatpak install flathub org.gnome.Totem
flatpak install flathub com.spotify.Client

# Productividad
flatpak install flathub org.libreoffice.LibreOffice
flatpak install flathub md.obsidian.Obsidian
flatpak install flathub com.github.flxzt.rnote

# Herramientas
flatpak install flathub com.github.wwmm.easyeffects
flatpak install flathub org.gnome.NetworkDisplays
```

---

## 4. Herramientas de desarrollo

### VS Code

```bash
# Via repositorio oficial de Microsoft
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install -y code
```

### Docker

```bash
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER
# Re-login para que tome efecto
docker --version
```

### Herramientas adicionales

```bash
# Python
sudo apt install -y python3 python3-pip python3-venv pipx

# Node.js via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
# Reabrir terminal, luego:
nvm install --lts

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Go
sudo apt install -y golang-go
```

---

## 5. GNOME — extensiones utiles

Instalar gestor de extensiones:

```bash
flatpak install flathub com.mattjakeman.ExtensionManager
```

Extensiones recomendadas:
- **Dash to Dock** — dock fijo en pantalla
- **GSConnect** — integracion con Android
- **Blur my Shell** — estetica
- **TopHat** — monitoreo de recursos en topbar
- **Caffeine** — evitar que se apague la pantalla

---

## 6. Fuentes tipograficas

```bash
sudo apt install -y fonts-firacode fonts-jetbrains-mono \
  fonts-noto fonts-noto-color-emoji
```

Para JetBrains Mono Nerd Font (icons en terminal):

```bash
mkdir -p ~/.local/share/fonts
wget -O /tmp/JetBrainsMono.zip \
  "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
unzip /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
fc-cache -fv
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

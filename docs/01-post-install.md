# 01 — Post-instalacion

## Estado: Pendiente

---

## Objetivos

- Configurar fuentes APT con `contrib`, `non-free` y `non-free-firmware`
- Actualizar el sistema completamente
- Instalar herramientas base
- Configurar locale y timezone

---

## 1. Fuentes APT

Editar `/etc/apt/sources.list` para incluir los repositorios necesarios
(en Debian Trixie los componentes non-free estan separados):

```bash
sudo nano /etc/apt/sources.list
```

Contenido recomendado:

```
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
```

Verificar:

```bash
grep -E "^deb" /etc/apt/sources.list
```

---

## 2. Actualizacion inicial

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y && sudo apt autoclean
```

---

## 3. Herramientas base

```bash
sudo apt install -y \
  git curl wget vim htop tree \
  build-essential dkms \
  apt-transport-https ca-certificates gnupg \
  lsb-release software-properties-common \
  unzip p7zip-full \
  net-tools nmap traceroute \
  rsync \
  bash-completion
```

---

## 4. Locale y timezone

Verificar configuracion actual:

```bash
locale
timedatectl status
```

Configurar si es necesario:

```bash
sudo dpkg-reconfigure locales       # seleccionar en_US.UTF-8
sudo timedatectl set-timezone America/ZONA
sudo timedatectl set-ntp true
```

---

## 5. Verificacion final

```bash
uname -r                 # version del kernel
cat /etc/debian_version  # version de Debian
dpkg --get-selections | wc -l  # paquetes instalados
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

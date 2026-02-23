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

La instalacion por defecto de Debian Trixie solo incluye `main non-free-firmware`.
Para instalar drivers NVIDIA y otro software propietario se necesita agregar
`contrib` y `non-free`.

Estado inicial del sources.list:
```
deb http://deb.debian.org/debian trixie main non-free-firmware
```

Agregar `contrib non-free` a todas las entradas con un solo comando:

```bash
sudo sed -i \
  -e 's/trixie main non-free-firmware$/trixie main contrib non-free non-free-firmware/' \
  -e 's/trixie-updates main non-free-firmware$/trixie-updates main contrib non-free non-free-firmware/' \
  -e 's/trixie-security main non-free-firmware$/trixie-security main contrib non-free non-free-firmware/' \
  -e 's/trixie-backports main non-free-firmware$/trixie-backports main contrib non-free non-free-firmware/' \
  /etc/apt/sources.list
```

Verificar resultado:

```bash
grep -E "^deb " /etc/apt/sources.list
```

Cada linea debe terminar en `contrib non-free non-free-firmware`.

---

## 2. Actualizacion inicial

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y && sudo apt autoclean
```

---

## 3. Herramientas base

Minimo necesario para el setup de esta maquina:

```bash
sudo apt install -y \
  build-essential dkms linux-headers-$(uname -r) \
  git curl \
  unzip
```

Razon de cada paquete:
- `build-essential` + `dkms` + `linux-headers` — requeridos para el driver NVIDIA y modulos del kernel
- `git` — control de versiones de esta documentacion
- `curl` — usado por instaladores de nvm, restic, etc.
- `unzip` — no viene por defecto, necesario para varios instaladores

El resto (`vim`, `htop`, `nmap`, etc.) se instala cuando surge la necesidad real.
Ver [10-software.md](10-software.md) para herramientas adicionales.

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

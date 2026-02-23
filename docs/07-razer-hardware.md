# 07 — Hardware Razer

## Estado: En Progreso

---

## Objetivos

- Instalar OpenRazer para control de hardware Razer
- Instalar Polychromatic (GUI para OpenRazer)
- Configurar iluminacion del teclado
- Ajustes del touchpad

---

## 1. OpenRazer

OpenRazer es el driver open-source para hardware Razer en Linux. Incluye un daemon (`openrazer-daemon`) y módulos de kernel que exponen el hardware (teclado RGB, touchpad, etc.) como dispositivos controlables.

**`openrazer-meta`** es un metapaquete que instala el daemon, los módulos DKMS y las dependencias de Python.

### Por qué repositorio externo y no el de Debian

OpenRazer **no está en los repositorios oficiales de Debian Trixie**. El proyecto mantiene su propio repositorio en OpenSUSE Build Service con paquetes actualizados para cada distribución, incluyendo `Debian_13`.

### Instalación aplicada

```bash
# Agregar repositorio
echo 'deb http://download.opensuse.org/repositories/hardware:/razer/Debian_13/ /' \
  | sudo tee /etc/apt/sources.list.d/hardware:razer.list

# Importar clave GPG del repositorio
curl -fsSL https://download.opensuse.org/repositories/hardware:razer/Debian_13/Release.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/trusted.gpg.d/hardware_razer.gpg > /dev/null

sudo apt update
sudo apt install openrazer-meta

# Agregar usuario al grupo plugdev (acceso a dispositivos USB)
sudo gpasswd -a $USER plugdev
```

El grupo `plugdev` es necesario para que `openrazer-daemon` tenga acceso a los dispositivos sin requerir root. Requiere **cerrar sesión y volver a entrar** (o reiniciar) para que tome efecto.

### Verificar

```bash
groups $USER | grep plugdev          # confirmar membresía al grupo
systemctl --user status openrazer-daemon
```

---

## 2. Polychromatic (GUI)

Polychromatic es la interfaz gráfica para OpenRazer. Permite controlar el RGB del teclado, crear efectos y perfiles. El proyecto mantiene su propio repositorio Debian.

### Instalación aplicada

```bash
# Importar clave GPG
curl -fsSL 'https://debian.polychromatic.app/key.asc' \
  | sudo gpg --dearmour -o /usr/share/keyrings/polychromatic.gpg

# Agregar repositorio (usa $VERSION_CODENAME = trixie)
source /etc/os-release
echo "deb [signed-by=/usr/share/keyrings/polychromatic.gpg] https://debian.polychromatic.app $VERSION_CODENAME main" \
  | sudo tee /etc/apt/sources.list.d/polychromatic.list

sudo apt-get update
sudo apt install polychromatic
```

Polychromatic permite:
- Cambiar efectos de iluminación del teclado (estático, respiración, onda, etc.)
- Perfiles por aplicación
- Control de DPI si hay mouse Razer

---

## 3. Touchpad

El touchpad de la Blade 14 funciona con `libinput`. Verificar:

```bash
libinput list-devices | grep -A 5 "Touchpad"
```

Configuracion via GNOME:

```
Configuracion > Mouse y Touchpad
```

Ajustes avanzados via xinput/libinput (Wayland):

```bash
sudo apt install -y libinput-tools
libinput debug-events --device /dev/input/eventX
```

Deshabilitar mientras se escribe (palm detection):

```bash
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
```

---

## 4. Teclado — atajos y macros

La Blade 14 tiene teclas multimedia funcionales por defecto en Linux.

Verificar teclas especiales:

```bash
sudo apt install -y xev   # no funciona en Wayland puro
# En Wayland usar:
sudo libinput debug-events --show-keycodes
```

Atajos personalizados via GNOME:

```
Configuracion > Teclado > Ver y personalizar atajos
```

---

## 5. Webcam

```bash
lsusb | grep -i cam
v4l2-ctl --list-devices
```

Instalar para prueba:

```bash
sudo apt install -y v4l-utils cheese
cheese    # abrir webcam
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

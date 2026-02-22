# 07 — Hardware Razer

## Estado: Pendiente

---

## Objetivos

- Instalar OpenRazer para control de hardware Razer
- Instalar Polychromatic (GUI para OpenRazer)
- Configurar iluminacion del teclado
- Ajustes del touchpad

---

## 1. OpenRazer

OpenRazer es el driver open-source para hardware Razer en Linux.

### Instalacion

La forma mas segura en Debian es via el repositorio oficial de OpenRazer:

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:openrazer/stable 2>/dev/null || \
  echo "deb http://download.opensuse.org/repositories/hardware:/razer/Debian_Testing/ /" \
    | sudo tee /etc/apt/sources.list.d/openrazer.list

# Alternativa: instalar desde el repo de Debian directamente
sudo apt install -y openrazer-meta
```

> Nota: verificar disponibilidad en Debian Trixie antes de agregar repos externos.
> Preferir el paquete de Debian si existe: `apt search openrazer`

Agregar usuario al grupo `plugdev`:

```bash
sudo gpasswd -a $USER plugdev
```

Reboot o re-login para que el grupo tome efecto.

### Verificar

```bash
sudo openrazer-daemon --version
openrazer-daemon -Fv &       # iniciar daemon en modo verbose
```

---

## 2. Polychromatic (GUI)

```bash
# Buscar en repositorios
sudo apt search polychromatic

# O instalar via Flatpak
flatpak install flathub tech.joshimeson.polychromatic
```

Polychromatic permite:
- Cambiar efectos de iluminacion del teclado (estatico, respiracion, onda, etc.)
- Perfiles por aplicacion
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

# Instalación y Configuración de NVIDIA en Razer Blade 14 — Debian Trixie

> **Equipo:** Razer Blade 14  
> **GPU:** NVIDIA RTX 4070 Max-Q / Mobile + AMD integrada  
> **OS:** Debian Trixie (13)  
> **Kernel:** 6.12.73+deb13-amd64  
> **Driver NVIDIA:** 550.163.01

---

## ⚠️ Orden importante antes de empezar

Antes de instalar los drivers, actualiza el sistema completo y reinicia para asegurarte de estar corriendo el kernel más reciente:

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

Esto evita inconsistencias entre la versión del kernel activo y los headers instalados.

---

## 1. Verificar el kernel activo

```bash
uname -r
```

Anota la versión, la necesitarás en el siguiente paso.

---

## 2. Instalar dependencias

```bash
sudo apt install linux-headers-$(uname -r) build-essential dkms
```

---

## 3. Detectar la GPU NVIDIA

```bash
sudo apt install nvidia-detect
nvidia-detect
```

Confirmará que la RTX 4070 Mobile es compatible y recomendará el paquete `nvidia-driver`.

---

## 4. Instalar el driver NVIDIA

Asegúrate de tener `non-free` y `non-free-firmware` habilitados en `/etc/apt/sources.list`. La línea debe verse así:

```
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
```

Luego instala:

```bash
sudo apt install nvidia-driver nvidia-kernel-dkms
sudo reboot
```

---

## 5. Verificar que NVIDIA funciona

```bash
nvidia-smi
```

Deberías ver la RTX 4070 con temperatura, uso de memoria y versión del driver.

---

## 6. Configuración de pantalla — Escala de texto

Esta laptop usa gráficos híbridos AMD+NVIDIA. Debian fuerza X11 con NVIDIA por estabilidad (Wayland con gráficos híbridos NVIDIA es inestable en Debian). Por eso las escalas fraccionarias nativas de GNOME no están disponibles.

La solución es usar el factor de escala de texto de GNOME:

```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.55
```

Ajusta el valor entre `1.25` y `1.75` según tu preferencia. Para una pantalla 2K de 14 pulgadas, `1.55` ofrece un buen balance.

---

## 7. Escala en la pantalla de login (GDM)

GDM tiene configuración separada. Para que el login se vea igual que la sesión:

```bash
sudo nano /etc/gdm3/greeter.dconf-defaults
```

Añade:

```ini
[org/gnome/desktop/interface]
text-scaling-factor=1.55
```

Aplica los cambios:

```bash
sudo dconf update
sudo systemctl restart gdm3
```

---

## 8. Tamaño del GRUB

El GRUB también tiene configuración independiente. Para agrandarlo edita:

```bash
sudo nano /etc/default/grub
```

Busca o añade:

```
GRUB_GFXMODE=1280x1024x32
```

Aplica:

```bash
sudo update-grub
```

Usa `1024x768x32` si quieres el texto aún más grande.

---

## Notas finales

- **X11 vs Wayland:** Debian deshabilita Wayland automáticamente cuando detecta NVIDIA mediante la regla `/usr/lib/udev/rules.d/61-gdm.rules`. Esto es intencional para evitar problemas de estabilidad con gráficos híbridos AMD+NVIDIA. Se recomienda no modificar esta regla.
- **DKMS:** El módulo NVIDIA se recompila automáticamente con cada actualización de kernel gracias a DKMS.
- **Actualizaciones:** Siempre haz `sudo apt upgrade` y reinicia antes de cambiar drivers o headers del kernel.

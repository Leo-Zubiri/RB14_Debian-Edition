# 02 — Drivers

## Estado: Completado (NVIDIA, AMD, WiFi)

---

## Contexto del hardware

| Componente | Detalle |
|------------|---------|
| dGPU | NVIDIA RTX 4070 Max-Q (Ada Lovelace) |
| iGPU | AMD Radeon 780M (RDNA 3, integrada en Ryzen 9 7940HS) |
| Kernel | 6.12.73+deb13-amd64 |
| Driver NVIDIA | 550.163.01 |
| Session | X11 (Debian deshabilita Wayland automáticamente con NVIDIA) |

> **Nota:** Debian deshabilita Wayland cuando detecta NVIDIA mediante la regla
> `/usr/lib/udev/rules.d/61-gdm.rules`. Esto es intencional para evitar
> problemas de estabilidad con gráficos híbridos AMD+NVIDIA. No modificar esta regla.

---

## 0. Prerrequisito: actualizar el sistema

Antes de instalar drivers, actualizar el sistema completo y reiniciar para
asegurarse de estar corriendo el kernel más reciente:

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

Esto evita inconsistencias entre el kernel activo y los headers instalados.

---

## 1. NVIDIA — prerequisitos

Verificar el kernel activo:

```bash
uname -r
```

Instalar headers y dependencias de compilación:

```bash
sudo apt install linux-headers-$(uname -r) build-essential dkms
```

Verificar que los headers coinciden con el kernel activo:

```bash
dpkg -l | grep linux-headers
```

Detectar la GPU NVIDIA y confirmar compatibilidad:

```bash
sudo apt install nvidia-detect
nvidia-detect
```

Confirmará que la RTX 4070 Mobile es compatible y recomendará el paquete `nvidia-driver`.

---

## 2. NVIDIA — instalacion del driver

Asegurarse de tener `non-free` y `non-free-firmware` en `/etc/apt/sources.list`
(ver [01-post-install.md](01-post-install.md)). La línea debe verse así:

```
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
```

Instalar el driver:

```bash
sudo apt install nvidia-driver nvidia-kernel-dkms
sudo reboot
```

> `nvidia-driver` es un metapaquete. `nvidia-kernel-dkms` compila el módulo
> del kernel via DKMS y lo recompila automáticamente con cada actualización de kernel.

---

## 3. NVIDIA — verificacion

```bash
nvidia-smi
```

Debe mostrar la RTX 4070 con temperatura, uso de memoria y versión del driver (550.x).

```bash
# Confirmar módulo cargado
modinfo nvidia | grep ^version

# Confirmar que X11 está activo (Wayland deshabilitado por Debian con NVIDIA)
echo $XDG_SESSION_TYPE   # debe mostrar: x11
```

---

## 4. AMD iGPU (Radeon 780M)

El driver `amdgpu` viene incluido en el kernel. No requiere instalación adicional.

Verificar que carga correctamente:

```bash
lsmod | grep amdgpu
dmesg | grep amdgpu | head -10
```

---

## 5. Firmware WiFi (Intel AX211)

La Blade 14 2023 usa Intel WiFi 6E AX211. Requiere firmware non-free:

```bash
sudo apt install -y firmware-iwlwifi
```

Aplicar sin reboot:

```bash
sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
```

Verificar:

```bash
iw dev                          # debe mostrar wlp3s0
rfkill list                     # verificar que no está bloqueado
dmesg | grep iwlwifi | tail -5
```

---

## 6. Parametros del kernel

Editar `/etc/default/grub`:

```bash
sudo nano /etc/default/grub
```

Agregar a `GRUB_CMDLINE_LINUX_DEFAULT`:

```
amd_pstate=active
```

- `amd_pstate=active` — driver de P-states moderno para Ryzen (mejor eficiencia energética)

```bash
sudo update-grub
sudo reboot
```

Verificar después del reboot:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
# Debe mostrar: amd_pstate_epp
```

---

## 7. Verificacion completa

```bash
# NVIDIA cargado
nvidia-smi

# Módulos cargados
lsmod | grep -E "nvidia|amdgpu|iwlwifi"

# Sesión activa
echo $XDG_SESSION_TYPE   # x11
```

---

## Notas

- DKMS recompila el módulo NVIDIA automáticamente con cada actualización de kernel.
- Siempre hacer `sudo apt upgrade` y reiniciar antes de cambiar drivers o headers del kernel.
- Para configuración de pantalla HiDPI ver [05-display.md](05-display.md).

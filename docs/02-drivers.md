# 02 — Drivers

## Estado: Pendiente

---

## Objetivos

- Instalar drivers NVIDIA propietarios con DKMS
- Configurar PRIME offloading (iGPU por defecto, dGPU bajo demanda)
- Verificar firmware de hardware (WiFi, Bluetooth, NVMe)
- Instalar OpenRazer para hardware Razer

---

## 1. NVIDIA

### Identificar GPU

```bash
lspci | grep -i nvidia
```

### Instalar driver

En Debian Trixie el driver NVIDIA esta disponible en `non-free`:

```bash
sudo apt install -y nvidia-driver nvidia-dkms nvidia-settings
```

> Requiere reboot despues de la instalacion.

Verificar:

```bash
nvidia-smi
modinfo nvidia | grep ^version
```

### PRIME offload (iGPU por defecto, dGPU on-demand)

Con GNOME + Wayland el PRIME sync es automatico con el driver moderno.
Verificar que el modo es correcto:

```bash
prime-select query        # debe mostrar 'on-demand' o 'intel/amd'
sudo prime-select on-demand
```

Para lanzar una aplicacion en la dGPU:

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia APLICACION
```

O usando el wrapper:

```bash
prime-run APLICACION
```

---

## 2. AMD iGPU (Radeon 780M)

El driver `amdgpu` esta incluido en el kernel. Verificar que carga:

```bash
lsmod | grep amdgpu
dmesg | grep amdgpu | head -20
```

Instalar herramientas de monitoreo:

```bash
sudo apt install -y radeontop
```

---

## 3. Firmware

### WiFi y Bluetooth

La Blade 14 2023 usa Intel WiFi 6E AX211:

```bash
lspci | grep -i wireless
```

Instalar firmware:

```bash
sudo apt install -y firmware-iwlwifi
sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
```

Verificar:

```bash
iw dev
rfkill list
```

### NVMe

```bash
lspci | grep -i nvme
sudo apt install -y nvme-cli
sudo nvme list
sudo nvme smart-log /dev/nvme0
```

---

## 4. Parametros del kernel para Razer Blade 14

Editar `/etc/default/grub`:

```bash
sudo nano /etc/default/grub
```

Agregar en `GRUB_CMDLINE_LINUX_DEFAULT`:

```
amd_pstate=active nvme_core.default_ps_max_latency_us=5500
```

Opciones explicadas:
- `amd_pstate=active`: driver de frecuencia de CPU moderno (mejor eficiencia)
- `nvme_core.default_ps_max_latency_us=5500`: reduce latencia del NVMe

Aplicar:

```bash
sudo update-grub
```

---

## 5. Verificacion general

```bash
lspci -k          # ver kernel drivers activos por dispositivo
lsmod             # modulos cargados
dmesg | grep -i "error\|fail" | grep -iv "acpi\|warning"
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

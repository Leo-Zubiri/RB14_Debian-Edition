# 04 — Gestion de energia

## Estado: Pendiente

---

## Objetivos

- Configurar TLP para optimizacion automatica en AC/bateria
- Limitar carga de bateria al 80% (salud a largo plazo)
- Gestionar estados de energia de la GPU NVIDIA
- Configurar CPU governor

---

## 1. TLP

```bash
sudo apt install -y tlp tlp-rdw
sudo systemctl enable --now tlp
```

### Limite de carga de bateria

La Blade 14 soporta limite via sysfs. TLP puede configurarlo:

```bash
sudo nano /etc/tlp.conf
```

Buscar y configurar:

```ini
# Limite de carga (0 = desactivado, 1-100 = porcentaje)
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80
```

Aplicar sin reboot:

```bash
sudo tlp start
sudo tlp-stat -b          # ver estado de bateria y limites
```

Verificar que el limite esta activo:

```bash
cat /sys/class/power_supply/BAT0/charge_control_end_threshold
```

---

## 2. CPU Governor

Con `amd_pstate=active` (configurado en drivers), el governor recomendado es `powersave`
(usa EPP — Energy Performance Preference — internamente):

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver      # debe ser amd_pstate_epp
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor    # powersave o performance
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
```

Configurar EPP via TLP en `/etc/tlp.conf`:

```ini
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power
```

---

## 3. NVIDIA — Power management

### RTD3 (Runtime D3 — suspension automatica de GPU)

Verificar soporte:

```bash
cat /proc/driver/nvidia/gpus/*/power
```

Configurar en `/etc/modprobe.d/nvidia-power.conf`:

```bash
sudo nano /etc/modprobe.d/nvidia-power.conf
```

```
options nvidia NVreg_DynamicPowerManagement=0x02
```

Esto permite que la GPU NVIDIA se suspenda automaticamente cuando no se usa.

Verificar estado despues de reboot:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
# debe mostrar "suspended" cuando la GPU no se usa
```

---

## 4. Consumo en tiempo real

```bash
sudo apt install -y powertop
sudo powertop                    # monitoreo interactivo
sudo powertop --calibrate        # calibracion (tarda ~20 min)
sudo powertop --html=report.html # reporte en HTML
```

Ver consumo actual:

```bash
cat /sys/class/power_supply/BAT0/power_now     # microwatts
tlp-stat -p                                     # resumen de CPU/GPU
```

---

## 5. Suspend e Hibernate

Verificar que suspend funciona:

```bash
sudo systemctl suspend
```

Estado del suspend:

```bash
cat /sys/power/mem_sleep          # debe incluir "deep"
```

Configurar deep sleep si no esta por defecto:

```bash
sudo nano /etc/default/grub
# Agregar a GRUB_CMDLINE_LINUX_DEFAULT: mem_sleep_default=deep
sudo update-grub
```

---

## 6. Temperatura y throttling

```bash
sudo apt install -y lm-sensors
sudo sensors-detect --auto
sensors

# Temperatura de CPU en tiempo real
watch -n 1 sensors
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

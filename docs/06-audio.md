# 06 — Audio

## Estado: Altavoces internos — Completado | PipeWire / BT — Pendiente

---

## Objetivos

- Verificar PipeWire funcionando correctamente
- Configurar Bluetooth audio (aptX, LDAC)
- Tuning basico de altavoces internos

---

## 1. Estado de PipeWire

Debian Trixie usa PipeWire por defecto. Verificar:

```bash
pactl info | grep "Server Name"          # debe mostrar PipeWire
systemctl --user status pipewire
systemctl --user status wireplumber
```

Si no esta activo:

```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

Paquetes necesarios:

```bash
sudo apt install -y pipewire pipewire-pulse pipewire-alsa \
  wireplumber libspa-0.2-bluetooth
```

---

## 2. Dispositivos de audio

```bash
pactl list sinks short          # salidas
pactl list sources short        # entradas (micros)
pw-dump | jq '.[] | select(.info.props."media.class" == "Audio/Device") | .info.props."node.name"'
```

Herramienta grafica:

```bash
sudo apt install -y pavucontrol
pavucontrol
```

---

## 3. Bluetooth Audio

### Verificar stack BT

```bash
systemctl status bluetooth
bluetoothctl show
```

### LDAC y aptX

Instalar soporte:

```bash
sudo apt install -y libspa-0.2-bluetooth bluez-alsa-utils
```

Para LDAC (requiere codec SBC-XQ o LDAC via pipewire-media-session):

```bash
# Verificar codecs disponibles
pactl list cards | grep -A 20 "Bluetooth"
```

Conectar dispositivo:

```bash
bluetoothctl
  power on
  scan on
  pair XX:XX:XX:XX:XX:XX
  connect XX:XX:XX:XX:XX:XX
  trust XX:XX:XX:XX:XX:XX
```

---

## 4. Altavoces internos — HDA codec fix (servicio systemd)

### Contexto

El codec Realtek ALC298 del Razer Blade 14 requiere una secuencia de inicialización
via `hda-verb` que **no persiste** entre reinicios ni después de suspender el equipo.
Sin este fix, los altavoces internos no producen sonido aunque PipeWire los detecte.

La solución usa dos mecanismos:
- Un **servicio systemd** (`Type=oneshot`) que corre el fix en cada arranque.
- Un **hook de systemd-sleep** que lo re-ejecuta tras salir de suspensión.

### Scripts

```
scripts/rb14_speakers/
├── RB14_2023_enable_internal_speakers_ver2.sh   # Fix (detecta ALC298 automáticamente)
└── install_rb14_speakers.sh                     # Instalador/desinstalador
```

### Instalación

```bash
cd ~/Documents/RB14_Debian-Edition/scripts/rb14_speakers
sudo bash install_rb14_speakers.sh install
```

El instalador:
1. Instala `alsa-tools` (contiene `hda-verb`) si no está presente.
2. Copia el script a `/usr/local/lib/rb14-speakers/fix.sh`.
3. Crea `/etc/systemd/system/rb14-speakers.service`.
4. Crea `/usr/lib/systemd/system-sleep/rb14-speakers` (hook de resume).
5. Habilita e inicia el servicio.

### Verificación

```bash
systemctl status rb14-speakers.service
# Active: active (exited) → correcto para Type=oneshot

systemctl is-enabled rb14-speakers.service
# enabled

journalctl -u rb14-speakers.service -n 50 --no-pager
```

### Cómo funciona

```
Boot
 └─► sound.target (ALSA listo)
      └─► rb14-speakers.service (oneshot)
           └─► udevadm settle + sleep 5 + fix.sh
                └─► ~1999 hda-verb → inicializa codec ALC298

Suspend/resume
 └─► systemd-sleep (post/*)
      └─► /usr/lib/systemd/system-sleep/rb14-speakers
           └─► re-ejecuta fix.sh
```

### Desinstalación

```bash
sudo bash install_rb14_speakers.sh uninstall
```

Elimina el servicio, el hook de sleep y `/usr/local/lib/rb14-speakers/`.
El script original no se toca.

---

## 5. Altavoces internos — EasyEffects

Los altavoces de la Blade 14 se benefician de EQ y compresion:

```bash
sudo apt install -y easyeffects
```

O via Flatpak (version mas actualizada):

```bash
flatpak install flathub com.github.wwmm.easyeffects
```

EasyEffects permite:
- Equalizer para compensar frecuencias debiles
- Limiter para evitar distorsion a volumen alto
- Bass enhancer

---

## 5. Verificacion de latencia

```bash
pw-top          # monitoreo de PipeWire en tiempo real
pw-cli info all | grep latency
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

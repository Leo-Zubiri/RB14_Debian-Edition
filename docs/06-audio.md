# 06 — Audio

## Estado: Pendiente

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

## 4. Altavoces internos — EasyEffects

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

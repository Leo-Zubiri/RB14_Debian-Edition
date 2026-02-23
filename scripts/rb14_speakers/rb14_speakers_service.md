# Razer Blade 14 2023 — Bocinas internas: servicio systemd

Guía para instalar, verificar, gestionar y eliminar el servicio que activa automáticamente las bocinas internas del Razer Blade 14 (2023) en Debian (y derivados con systemd).

---

## Contexto

El codec de audio (HDA) del Razer Blade 14 2023 requiere una secuencia de inicialización mediante `hda-verb` que **no persiste entre reinicios ni después de suspender el equipo**. El script `RB14_2023_enable_internal_speakers_ver2.sh` contiene esa secuencia.

La solución consiste en:

- Un **servicio systemd** que ejecuta el script en cada arranque.
- Un **hook de systemd-sleep** que lo re-ejecuta después de salir de suspensión o hibernación.

---

## Archivos involucrados

| Archivo | Descripción |
|---|---|
| `RB14_2023_enable_internal_speakers_ver2.sh` | Script original (no mover) |
| `install_rb14_speakers.sh` | Instalador/desinstalador (este script) |
| `/usr/local/lib/rb14-speakers/fix.sh` | Copia del script instalada por el servicio |
| `/etc/systemd/system/rb14-speakers.service` | Unidad systemd del servicio |
| `/lib/systemd/system-sleep/rb14-speakers` | Hook que se activa tras suspensión/hibernación |

---

## Requisitos previos

- Debian Trixie (o cualquier distro con systemd)
- El paquete `alsa-tools` (contiene `hda-verb`) — el instalador lo descarga automáticamente si falta

---

## Instalación

Ambos archivos deben estar en el **mismo directorio** antes de instalar.

```bash
cd ~/Downloads
sudo bash install_rb14_speakers.sh install
```

El script realiza automáticamente:

1. Verifica que `hda-verb` esté instalado (instala `alsa-tools` si falta).
2. Copia el script de audio a `/usr/local/lib/rb14-speakers/fix.sh`.
3. Crea la unidad systemd en `/etc/systemd/system/rb14-speakers.service`.
4. Crea el hook de sleep en `/lib/systemd/system-sleep/rb14-speakers`.
5. Habilita el servicio (arranque automático) y lo inicia inmediatamente.

---

## Verificación

### Estado del servicio

```bash
systemctl status rb14-speakers.service
```

Salida esperada (servicio activo):

```
● rb14-speakers.service - Razer Blade 14 2023 - Bocinas internas (HDA codec fix)
     Loaded: loaded (/etc/systemd/system/rb14-speakers.service; enabled; ...)
     Active: active (exited) since ...
```

### Confirmar que está habilitado para arranque automático

```bash
systemctl is-enabled rb14-speakers.service
# Debe responder: enabled
```

### Ver logs del servicio

```bash
journalctl -u rb14-speakers.service
```

Para ver solo la última ejecución:

```bash
journalctl -u rb14-speakers.service -n 50 --no-pager
```

### Verificar el hook de sleep

```bash
ls -la /lib/systemd/system-sleep/rb14-speakers
```

---

## Gestión del servicio

### Iniciar manualmente (sin reiniciar)

```bash
sudo systemctl start rb14-speakers.service
```

### Detener (solo en sesión actual, no deshabilita el arranque automático)

```bash
sudo systemctl stop rb14-speakers.service
```

### Deshabilitar temporalmente el arranque automático

```bash
sudo systemctl disable rb14-speakers.service
```

Para volver a habilitarlo:

```bash
sudo systemctl enable rb14-speakers.service
```

---

## Desinstalación

```bash
sudo bash install_rb14_speakers.sh uninstall
```

Esto elimina:

- El servicio systemd (y lo deshabilita).
- El hook de sleep.
- El directorio `/usr/local/lib/rb14-speakers/`.

El script original `RB14_2023_enable_internal_speakers_ver2.sh` **no se toca**.

---

## Solución de problemas

### Las bocinas siguen sin funcionar después de instalar

1. Verifica que el servicio terminó sin errores:

   ```bash
   journalctl -u rb14-speakers.service -n 100 --no-pager
   ```

2. Comprueba que el dispositivo de audio existe:

   ```bash
   ls /dev/snd/hwC2D0
   ```

   Si no existe, el número de tarjeta puede haber cambiado. Revisa con:

   ```bash
   ls /dev/snd/hw*
   ```

   Si el dispositivo tiene un nombre distinto (p.ej. `hwC0D0`), edita el script instalado:

   ```bash
   sudo nano /usr/local/lib/rb14-speakers/fix.sh
   # Reemplaza C2D0 por el número correcto con búsqueda/reemplazo (Ctrl+\)
   ```

   Luego reinicia el servicio:

   ```bash
   sudo systemctl restart rb14-speakers.service
   ```

3. Verifica que `hda-verb` funciona manualmente:

   ```bash
   sudo hda-verb /dev/snd/hwC2D0 0x20 0x500 0x7
   ```

### El servicio falla con "unit not found" después de desinstalar

```bash
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

### Las bocinas dejan de funcionar después de suspender

Verifica que el hook de sleep existe y es ejecutable:

```bash
ls -la /lib/systemd/system-sleep/rb14-speakers
```

Prueba ejecutarlo manualmente simulando un resume:

```bash
sudo /lib/systemd/system-sleep/rb14-speakers post suspend
```

---

## Actualizar el script de audio

Si obtienes una versión nueva del script de corrección:

```bash
# Reemplaza el archivo instalado
sudo cp RB14_2023_enable_internal_speakers_ver2.sh /usr/local/lib/rb14-speakers/fix.sh
sudo chmod 755 /usr/local/lib/rb14-speakers/fix.sh

# Reinicia el servicio para aplicar los cambios
sudo systemctl restart rb14-speakers.service
```

---

## Cómo funciona internamente

```
Arranque del sistema
       │
       ▼
 sound.target (ALSA listo)
       │
       ▼
 rb14-speakers.service
       │
       └─► /bin/bash /usr/local/lib/rb14-speakers/fix.sh
             └─► 1999 comandos hda-verb → configura el codec de audio

Suspensión/hibernación
       │
       ▼
 systemd-sleep
       │
       ├─► pre/suspend  → (sin acción)
       │
       └─► post/suspend → /lib/systemd/system-sleep/rb14-speakers
                               └─► re-ejecuta fix.sh
```


journalctl -u rb14-speakers.service -n 50 --no-pager

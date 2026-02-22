# 09 — Backups

## Estado: Pendiente

---

## Objetivos

- Snapshots del sistema con Timeshift (rollback ante actualizaciones o errores)
- Backup de datos de usuario con restic o borgbackup
- Estrategia 3-2-1: 3 copias, 2 medios, 1 offsite

---

## 1. Timeshift — snapshots del sistema

Timeshift hace snapshots de `/` (excluyendo `/home`) para restauracion rapida.

### Instalacion

```bash
sudo apt install -y timeshift
```

### Configuracion

```bash
sudo timeshift --setup    # wizard interactivo
```

Recomendaciones:
- Tipo: **RSYNC** (mas compatible que BTRFS si el FS es ext4)
- Frecuencia: snapshot diario, conservar los ultimos 5
- Excluir `/home` del snapshot del sistema (backup separado)

Crear snapshot manual antes de cambios importantes:

```bash
sudo timeshift --create --comments "Antes de instalar NVIDIA drivers"
sudo timeshift --list
```

Restaurar:

```bash
sudo timeshift --restore --snapshot '2024-XX-XX_XX-XX-XX'
```

---

## 2. Restic — backup de datos de usuario

Restic es un backup tool moderno, encriptado y eficiente.

### Instalacion

```bash
sudo apt install -y restic
```

### Inicializar repositorio

En disco externo:

```bash
restic init --repo /media/razer/DISCO_EXTERNO/backups/blade14
```

En almacenamiento remoto (ej. Backblaze B2):

```bash
restic init --repo b2:BUCKET_NAME:blade14
```

### Primer backup

```bash
restic -r /RUTA/AL/REPO backup /home/razer \
  --exclude="/home/razer/.cache" \
  --exclude="/home/razer/.local/share/Trash" \
  --exclude="/home/razer/Downloads" \
  --tag manual
```

### Backup automatico con systemd

Crear `/etc/systemd/system/restic-backup.service`:

```ini
[Unit]
Description=Restic Backup
After=network.target

[Service]
Type=oneshot
User=razer
EnvironmentFile=/etc/restic/env
ExecStart=/usr/bin/restic -r ${RESTIC_REPOSITORY} backup /home/razer \
  --exclude="/home/razer/.cache" \
  --exclude="/home/razer/.local/share/Trash" \
  --tag auto
ExecStartPost=/usr/bin/restic -r ${RESTIC_REPOSITORY} forget \
  --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --prune
```

Crear `/etc/systemd/system/restic-backup.timer`:

```ini
[Unit]
Description=Restic Backup Timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl enable --now restic-backup.timer
systemctl list-timers restic-backup.timer
```

### Verificar integridad

```bash
restic -r /RUTA/AL/REPO check
restic -r /RUTA/AL/REPO snapshots
```

### Restaurar archivos

```bash
restic -r /RUTA/AL/REPO restore latest --target /tmp/restore
restic -r /RUTA/AL/REPO restore latest --target / --include "/home/razer/Documents"
```

---

## 3. Estrategia recomendada

| Tipo | Herramienta | Frecuencia | Destino |
|------|------------|------------|---------|
| Sistema | Timeshift | Diario | Disco local (particion separada) |
| Datos | Restic | Diario | Disco externo |
| Datos | Restic | Semanal | Nube (B2, S3, etc.) |

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

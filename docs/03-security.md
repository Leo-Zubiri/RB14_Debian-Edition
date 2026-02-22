# 03 — Seguridad

## Estado: Pendiente

---

## Objetivos

- Firewall con UFW
- AppArmor activo y con perfiles
- fail2ban para proteccion de servicios
- Hardening del kernel via sysctl
- Actualizaciones de seguridad automaticas
- Auditoria con lynis

---

## 1. UFW (Firewall)

```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw status verbose
```

Reglas opcionales (solo agregar si el servicio existe):

```bash
sudo ufw allow ssh          # solo si usas SSH
sudo ufw allow 80/tcp       # solo si corres servidor web
```

---

## 2. AppArmor

Verificar que esta activo (en Debian Trixie viene activo por defecto):

```bash
sudo aa-status
```

Instalar perfiles adicionales:

```bash
sudo apt install -y apparmor-profiles apparmor-profiles-extra apparmor-utils
sudo aa-enforce /etc/apparmor.d/*
sudo aa-status | grep enforce
```

---

## 3. fail2ban

```bash
sudo apt install -y fail2ban
```

Crear configuracion local (no tocar el `.conf` original):

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Configuracion minima recomendada en `[DEFAULT]`:

```ini
bantime  = 1h
findtime = 10m
maxretry = 5
```

```bash
sudo systemctl enable --now fail2ban
sudo fail2ban-client status
```

---

## 4. Hardening del kernel (sysctl)

Crear `/etc/sysctl.d/99-hardening.conf`:

```bash
sudo nano /etc/sysctl.d/99-hardening.conf
```

Contenido:

```ini
# Deshabilitar IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Proteccion contra SYN flood
net.ipv4.tcp_syncookies = 1

# Ignorar pings broadcast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Proteccion contra spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Deshabilitar aceptar redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Deshabilitar source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Proteger dmesg (solo root)
kernel.dmesg_restrict = 1

# Deshabilitar magic sysrq en produccion
kernel.sysrq = 0

# Ocultar punteros del kernel
kernel.kptr_restrict = 2

# Proteger /proc
kernel.perf_event_paranoid = 3
```

Aplicar:

```bash
sudo sysctl --system
sudo sysctl -p /etc/sysctl.d/99-hardening.conf
```

---

## 5. Actualizaciones de seguridad automaticas

```bash
sudo apt install -y unattended-upgrades apt-listchanges
sudo dpkg-reconfigure -plow unattended-upgrades
```

Verificar configuracion:

```bash
cat /etc/apt/apt.conf.d/50unattended-upgrades | grep -v "^//"
```

---

## 6. Auditoria con Lynis

```bash
sudo apt install -y lynis
sudo lynis audit system
```

El reporte va a `/var/log/lynis.log` y el resultado de hardening a `/var/log/lynis-report.dat`.

Objetivo: **Hardening index > 70**.

---

## 7. Servicios innecesarios

Listar servicios activos:

```bash
systemctl list-units --type=service --state=running
```

Deshabilitar servicios no usados (ejemplos):

```bash
sudo systemctl disable --now bluetooth    # si no usas Bluetooth
sudo systemctl disable --now cups         # si no usas impresora
```

---

## 8. Permisos SUID/SGID

Auditar binarios con SUID:

```bash
find / -perm /4000 -type f 2>/dev/null | sort
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

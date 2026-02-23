# Razer Blade 14 (2023) — Debian Trixie

Guia de configuracion, hardening y optimizacion del sistema.
Documentacion acumulativa: cada seccion refleja el estado real del equipo.

---

## Sistema

| Campo       | Valor                                      |
|-------------|---------------------------------------------|
| Host        | Razer Blade 14 — RZ09-0482 (9.04)          |
| OS          | Debian GNU/Linux 13 (trixie) x86_64        |
| Kernel      | Linux 6.12.73+deb13-amd64                  |
| CPU         | AMD Ryzen 9 7940HS (16 threads) @ 5.26 GHz |
| GPU         | NVIDIA RTX 4070 Max-Q + AMD Radeon 780M    |
| RAM         | 30.57 GiB                                  |
| Disco       | 904.43 GiB ext4                             |
| Pantalla    | 2560x1600 @ 240 Hz (14", Built-in)         |
| DE / WM     | GNOME 48.7 / Mutter (X11)                 |

---

## Indice de documentacion

| # | Seccion | Descripcion |
|---|---------|-------------|
| 01 | [Post-instalacion](docs/01-post-install.md) | Fuentes APT, actualizacion inicial, herramientas base |
| 02 | [Drivers](docs/02-drivers.md) | NVIDIA, PRIME offload, firmware, openrazer |
| 03 | [Seguridad](docs/03-security.md) | Firewall, AppArmor, fail2ban, hardening del kernel |
| 04 | [Gestion de energia](docs/04-power-management.md) | TLP, limites de bateria, GPU power states |
| 05 | [Pantalla](docs/05-display.md) | HiDPI, 240 Hz, color profiles, Wayland |
| 06 | [Audio](docs/06-audio.md) | PipeWire, Bluetooth, tuning de altavoces |
| 07 | [Hardware Razer](docs/07-razer-hardware.md) | OpenRazer, RGB, teclado, touchpad |
| 08 | [Red y VPN](docs/08-networking.md) | DNS seguro, firewall de red, VPN |
| 09 | [Backups](docs/09-backups.md) | Timeshift, restic, estrategia de snapshots |
| 10 | [Software](docs/10-software.md) | Paquetes esenciales, Flatpak, herramientas dev |

---

## Estado

| Seccion | Estado |
|---------|--------|
| Post-instalacion | Pendiente |
| Drivers | Completado |
| Seguridad | Pendiente |
| Gestion de energia | Pendiente |
| Pantalla | Completado |
| Audio | Pendiente |
| Hardware Razer | Pendiente |
| Red y VPN | Pendiente |
| Backups | Pendiente |
| Software | Pendiente |

---

## Uso

Cada archivo en `docs/` contiene:
- El contexto del problema o configuracion
- Los comandos exactos ejecutados
- El resultado esperado y verificacion
- Notas de troubleshooting si aplica

Los scripts utilitarios van en `scripts/`.

```bash
git log --oneline   # ver historial de cambios al sistema
```

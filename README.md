# Razer Blade 14 (2023) — Debian Trixie

> Guía de configuración, hardening y optimización del sistema.
> Documentación acumulativa: cada sección refleja el estado real del equipo.

---

## Sistema

```
        _,met$$$gg.          razer@blade
     ,g$$$$$$$$P.            -----------
   ,g$P""       """Y$.".     OS: Debian GNU/Linux 13 (trixie) x86_64
  ,$P'              `$$.     Host: Blade 14 - RZ09-0482 (9.04)
',$P       ,ggs.     `$b:    Kernel: Linux 6.12.73+deb13-amd64
`d$'     ,$P"'   .    $$     Packages: 2406 (dpkg)
 $P      d$'     ,    $P     Shell: bash 5.2.37
 $:      $.   -    ,d$'      Display: 2560x1600 @ 240 Hz in 14" [Built-in]
 $;      Y$b._   _,d$P'      DE: GNOME 48.7
 Y$.    `.`"Y$$P"'           WM: Mutter (Wayland)
 `$b      "-.__              CPU: AMD Ryzen 9 7940HS (16) @ 5.26 GHz
  `Y$b                       GPU 1: NVIDIA GeForce RTX 4070 Max-Q [Discrete]
   `Y$.                      GPU 2: AMD Radeon 780M [Integrated]
     `$b.                    Memory: 4.60 GiB / 30.57 GiB (15%)
       `Y$b.                 Disk (/): 11.54 GiB / 904.43 GiB (1%) - ext4
         `"Y$b._             Battery: 79% [AC Connected]
             `""""           Locale: en_US.UTF-8
```

---

## Documentación

| #  | Sección                                                       | Descripción                                          | Estado         |
|----|---------------------------------------------------------------|------------------------------------------------------|----------------|
| 01 | [Post-instalación](docs/01-post-install.md)                  | Fuentes APT, actualización inicial, herramientas base | ⏳ Pendiente   |
| 02 | [Drivers](docs/02-drivers.md)                                | NVIDIA, PRIME offload, firmware, openrazer            | ✅ Completado  |
| 03 | [Seguridad](docs/03-security.md)                             | Firewall, AppArmor, fail2ban, hardening del kernel    | ⏳ Pendiente   |
| 04 | [Gestión de energía](docs/04-power-management.md)            | TLP, límites de batería, GPU power states             | ⏳ Pendiente   |
| 05 | [Pantalla](docs/05-display.md)                               | HiDPI, 240 Hz, color profiles, migración X11→Wayland | ✅ Completado  |
| 06 | [Audio](docs/06-audio.md)                                    | Altavoces internos (HDA fix), PipeWire, Bluetooth     | 🔧 En progreso |
| 07 | [Hardware Razer](docs/07-razer-hardware.md)                  | OpenRazer, RGB, teclado, touchpad                     | ⏳ Pendiente   |
| 08 | [Red y VPN](docs/08-networking.md)                           | DNS seguro, firewall de red, VPN                      | ⏳ Pendiente   |
| 09 | [Backups](docs/09-backups.md)                                | Timeshift, restic, estrategia de snapshots            | ⏳ Pendiente   |
| 10 | [Software](docs/10-software.md)                              | Paquetes esenciales, Flatpak, herramientas dev        | ⏳ Pendiente   |

---

## Scripts

| Script | Descripción |
|--------|-------------|
| [scripts/rb14_speakers/](scripts/rb14_speakers/) | Fix altavoces internos — servicio systemd + hook de resume |

---

## Uso

Cada archivo en `docs/` documenta el contexto del problema, los comandos exactos
ejecutados, el resultado esperado y notas de troubleshooting.

```bash
git log --oneline   # historial de cambios al sistema
```

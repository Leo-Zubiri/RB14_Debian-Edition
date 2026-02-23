# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Personal configuration and documentation repository for a **Razer Blade 14 2023** (RZ09-0482) running **Debian Trixie (13)**. This is a living reference that records the exact commands, configs, and solutions applied to this specific machine.

**Hardware:**
- CPU: AMD Ryzen 9 7940HS | RAM: 32GB
- GPU: NVIDIA RTX 4070 Max-Q (dGPU) + AMD Radeon 780M (iGPU)
- Display: 2560×1600 @ 240Hz | Audio: Realtek ALC298
- Network: Intel WiFi 6E AX211

**Current system state:** Debian Trixie, kernel 6.12.73+deb13-amd64, X11 session (Wayland not used due to NVIDIA hybrid graphics), GNOME desktop.

## Speaker Fix Service (scripts/)

The most technically complex component. The Realtek ALC298 codec loses its configuration after every boot and suspend—fixed by replaying ~1999 `hda-verb` commands.

### Install / Uninstall
```bash
cd scripts/rb14_speakers
sudo bash install_rb14_speakers.sh install
sudo bash install_rb14_speakers.sh uninstall
```

The installer requires `hda-verb` from the `alsa-tools` package (auto-installs if missing). It deploys:
- `/usr/local/lib/rb14-speakers/fix.sh` — the codec fix script
- `/etc/systemd/system/rb14-speakers.service` — runs at boot after `sound.target`
- `/usr/lib/systemd/system-sleep/rb14-speakers` — re-runs fix after suspend/hibernate

### Service verification
```bash
systemctl status rb14-speakers.service
journalctl -u rb14-speakers.service -n 50 --no-pager
sudo /usr/local/lib/rb14-speakers/fix.sh          # manual test
sudo /lib/systemd/system-sleep/rb14-speakers post suspend  # simulate resume
```

### How the fix script works
`RB14_2023_enable_internal_speakers_ver2.sh` auto-detects the ALC298 codec in `/proc/asound/card*/codec#*`, resolves the device path (`/dev/snd/hwC*D0`), then executes the hda-verb sequence. It exits with an error if the codec is not found.

## Documentation Structure (`docs/`)

Sequential numbered guides reflecting the real configuration order applied:

| File | Topic | Status |
|------|-------|--------|
| `01-post-install.md` | APT sources (contrib, non-free), base packages | Pending |
| `02-drivers.md` | NVIDIA 550.163.01 (DKMS), AMD, WiFi firmware, kernel params | Completed |
| `03-security.md` | UFW, AppArmor, fail2ban, sysctl hardening | Pending |
| `04-power-management.md` | TLP (battery at 75–80%), NVIDIA RTD3, CPU governors | Pending |
| `05-display.md` | HiDPI (scale 1.55), GDM/GRUB scaling, 240Hz, Wayland option | Completed |
| `06-audio.md` | PipeWire, Bluetooth, speaker service, EasyEffects | In Progress |
| `07-razer-hardware.md` | OpenRazer, Polychromatic, touchpad, keyboard, webcam | Pending |
| `08-networking.md` | DNS DoT/DoH, NetworkManager privacy, WireGuard VPN | Pending |
| `09-backups.md` | Timeshift snapshots, Restic encrypted backups | Pending |
| `10-software.md` | Flatpak apps, dev tools, GNOME extensions, fonts | Pending |

`nvidia-razer-blade-14-debian.md` — standalone detailed guide for the full NVIDIA driver installation process.

## Key Technical Context

- **Display:** X11 forced by Debian due to NVIDIA hybrid GPU; HiDPI via `text-scaling-factor=1.55` in GNOME (fractal scaling unavailable on X11).
- **Audio stack:** PipeWire + WirePlumber + pipewire-pulse. Internal speakers only work after the `rb14-speakers` service runs.
- **NVIDIA:** Driver 550.163.01 with DKMS (auto-recompiles on kernel updates). RTD3 enabled for automatic GPU power suspension.
- **CPU power:** `amd_pstate=active` kernel parameter enables modern P-states with EPP.
- **Documentation language:** Spanish throughout all `.md` files.

## Documentation Conventions

- Each doc section reflects actual machine state—commands shown are the exact ones executed.
- Include expected output or verification steps after each configuration block.
- Cross-reference related sections when configurations interact (e.g., audio + power management).
- Keep status accurate: mark sections as Completado / En Progreso / Pendiente.

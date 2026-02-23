# 05 — Pantalla

## Estado: Completado (HiDPI, GDM, GRUB)

---

## Contexto

La pantalla es 2560x1600 en 14". Con NVIDIA híbrido, Debian fuerza **X11** (Wayland
se deshabilita automáticamente). En X11, las escalas fraccionarias nativas de GNOME
no están disponibles; la solución es `text-scaling-factor`.

---

## 1. Escala HiDPI — sesion

Usar el factor de escala de texto de GNOME:

```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.55
```

Ajustar el valor entre `1.25` y `1.75` según preferencia. Para la pantalla 2560x1600
de 14 pulgadas, `1.55` ofrece un buen balance entre espacio y legibilidad.

Verificar:

```bash
gsettings get org.gnome.desktop.interface text-scaling-factor
```

---

## 2. Escala en la pantalla de login (GDM)

GDM tiene configuración separada. Para que el login se vea igual que la sesión:

```bash
sudo nano /etc/gdm3/greeter.dconf-defaults
```

Añadir o editar:

```ini
[org/gnome/desktop/interface]
text-scaling-factor=1.55
```

Aplicar los cambios:

```bash
sudo dconf update
sudo systemctl restart gdm3
```

---

## 3. Tamaño del GRUB

El GRUB también tiene configuración independiente. Para agrandarlo:

```bash
sudo nano /etc/default/grub
```

Buscar o añadir:

```
GRUB_GFXMODE=1280x1024x32
```

Aplicar:

```bash
sudo update-grub
```

Usar `1024x768x32` si se quiere el texto aún más grande.

---

## 4. Frecuencia de refresco (240 Hz)

Verificar modo actual en X11:

```bash
xrandr | grep -E "connected|Hz"
```

La pantalla debe aparecer con el modo 2560x1600 y la frecuencia activa marcada con `*`.
La frecuencia se puede cambiar desde `Configuracion > Pantallas`.

---

## 5. Perfil de color

La Blade 14 tiene un panel con perfil sRGB. GNOME puede cargar perfiles ICC.

Instalar colord si no está:

```bash
sudo apt install -y colord
```

Cargar perfil desde GNOME: `Configuracion > Color > Agregar perfil`.

---

## 6. Night Light

GNOME incluye Night Light integrado:

```
Configuracion > Pantallas > Night Light
```

O via terminal:

```bash
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
```

---

---

## 7. Migración a Wayland

### ¿Por qué Debian fuerza X11 con drivers privativos de NVIDIA?

Al instalar los drivers privativos de NVIDIA, Debian detecta automáticamente que el
driver propietario está activo y aplica una regla udev que **deshabilita Wayland**
como medida de compatibilidad preventiva.

El archivo responsable es:

```
/usr/lib/udev/rules.d/61-gdm.rules
```

Esta regla hace que GDM fuerce la sesión a **X11**, ignorando Wayland por completo.
En X11, la escala solo soporta valores enteros (100%, 200%...), sin posibilidad de
escalas fraccionadas nativas. **Wayland** soporta fractional scaling (125%, 150%,
175%), ideal para la pantalla 2560x1600 del Razer Blade 14.

### Pasos para habilitar Wayland

**1. Habilitar nvidia-drm modesetting**

```bash
sudo nano /etc/default/grub
```

Agregar `nvidia-drm.modeset=1` en `GRUB_CMDLINE_LINUX_DEFAULT`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"
```

```bash
sudo update-grub
```

**2. Anular la regla que fuerza X11**

```bash
sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
```

Crea un symlink a `/dev/null` que neutraliza la regla original sin eliminarla.

**3. Reiniciar y seleccionar sesión Wayland**

En la pantalla de login, hacer clic en el engrane (⚙) antes de ingresar la
contraseña y seleccionar **GNOME (Wayland)**.

**4. Activar fractional scaling**

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Luego ir a **Configuración → Pantallas** y seleccionar la escala deseada.

---

## Notas

- La escala fraccional nativa de GNOME (experimental-features) no aplica en X11.
- `text-scaling-factor` escala el texto y la UI pero no el framebuffer completo;
  es la solución correcta para X11 en pantallas HiDPI.
- Los cambios en `greeter.dconf-defaults` requieren `dconf update` para aplicarse.
- Algunas apps sin soporte Wayland nativo (Electron, Qt antiguas) correrán en modo
  **XWayland** y pueden verse ligeramente borrosas.
- Para volver a X11: seleccionar **GNOME (X11)** desde el engrane en el login.
- Para deshacer la anulación de udev: `sudo rm /etc/udev/rules.d/61-gdm.rules`

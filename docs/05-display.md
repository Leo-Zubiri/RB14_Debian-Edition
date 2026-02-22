# 05 — Pantalla

## Estado: Pendiente

---

## Objetivos

- Verificar y configurar 240 Hz en Wayland
- Escala HiDPI correcta (2560x1600 en 14")
- Perfil de color
- Night Light / Redshift

---

## 1. Resolucion y frecuencia

Verificar modo actual:

```bash
# En Wayland con GNOME
wayland-info 2>/dev/null | grep -i refresh || \
  gdbus call --session \
    --dest org.gnome.Mutter.DisplayConfig \
    --object-path /org/gnome/Mutter/DisplayConfig \
    --method org.gnome.Mutter.DisplayConfig.GetCurrentState
```

Alternativa con wlr-randr (si disponible):

```bash
sudo apt install -y wlr-randr
wlr-randr
```

O via herramienta GNOME:

```
Configuracion > Pantallas > Frecuencia de actualizacion > 240 Hz
```

---

## 2. Escala HiDPI

La pantalla es 2560x1600 en 14". La escala recomendada para GNOME/Wayland es **175%** o **200%**.

Verificar escala actual:

```bash
gsettings get org.gnome.desktop.interface scaling-factor
gsettings get org.gnome.mutter experimental-features
```

Habilitar escalado fraccional en GNOME (Wayland):

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Luego ir a `Configuracion > Pantallas` y seleccionar la escala deseada.

Escala recomendada segun uso:
- **175%** — balance entre espacio y legibilidad
- **200%** — maxima legibilidad

---

## 3. Perfil de color

La Blade 14 tiene un panel con perfil sRGB. GNOME puede cargar perfiles ICC.

Instalar colord si no esta:

```bash
sudo apt install -y colord
```

El perfil de Razer para este panel suele encontrarse en:
- `/usr/share/color/icc/`
- O descargarse desde el sitio de Razer / Notebook Check

Cargar perfil:

```bash
# Via GNOME Settings > Color > Add profile
```

---

## 4. Night Light

GNOME incluye Night Light integrado:

```
Configuracion > Pantallas > Night Light
```

O via terminal:

```bash
# Activar Night Light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
```

---

## 5. Verificacion

```bash
# Ver informacion del monitor
sudo apt install -y edid-decode
sudo get-edid | edid-decode

# Ver backend de render
glxinfo | grep "OpenGL renderer"
vulkaninfo --summary 2>/dev/null | head -20
```

---

## Notas

<!-- Agregar notas y resultados al ejecutar -->

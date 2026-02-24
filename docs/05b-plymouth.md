# 05b — Plymouth (splash screen de arranque)

## Estado: Completado — tema activo: `bgrt`

---

## Contexto

**Plymouth** es el gestor de splash screen de Linux. Muestra una animación durante
el arranque y apagado del sistema, mientras el kernel carga módulos y systemd
inicializa los servicios. Sin Plymouth, el arranque expone texto crudo del kernel
(incluso con `loglevel=3` en GRUB, algunos mensajes son visibles).

Con el tema de GRUB personalizado ya instalado (ver `05-display.md` §3), tiene
sentido que el splash screen continúe la experiencia visual en lugar de romperla
con texto o el tema genérico de Debian.

**Consideración con NVIDIA híbrido:** Plymouth opera en modo framebuffer antes de
que los drivers propietarios de NVIDIA carguen. Esto es normal — la resolución
del splash puede ser inferior a la nativa; al llegar al login de GDM ya aplica
la resolución completa.

---

## 1. Instalación

```bash
sudo apt install plymouth plymouth-themes
```

Verificar que está instalado:

```bash
plymouth --version
```

---

## 2. Temas disponibles

Listar los temas instalados:

```bash
sudo /usr/sbin/plymouth-set-default-theme --list
```

Salida esperada (temas incluidos en `plymouth-themes`):

```
bgrt
details
fade-in
glow
joy
lines
moonlight
script
solar
softwaves
spinfinity
spinner
text
tribar
```

### Descripción de los más relevantes

| Tema | Descripción |
|------|-------------|
| `spinner` | Círculo minimalista sobre fondo negro — el más limpio |
| `spinfinity` | Spinner elaborado con logo del sistema |
| `moonlight` | Oscuro y elegante, ondas sutiles |
| `softwaves` | Ondas suaves animadas |
| `solar` | Efecto de partículas de luz — más llamativo |
| `bgrt` | Muestra el logo ACPI del fabricante (Razer) — **tema aplicado** |
| `details` | Muestra el texto del kernel sin animación — útil para depuración |

---

## 3. Aplicar un tema

```bash
sudo /usr/sbin/plymouth-set-default-theme spinner
sudo update-initramfs -u
```

`update-initramfs -u` es obligatorio: Plymouth se incluye en el initramfs, por lo
que el tema no se aplica hasta regenerarlo.

Verificar el tema activo:

```bash
sudo /usr/sbin/plymouth-set-default-theme
```

---

## 4. Probar sin reiniciar

Simular el arranque de Plymouth (en TTY, fuera de sesión gráfica):

```bash
sudo plymouthd --no-daemon --debug
sudo plymouth show-splash
sleep 5
sudo plymouth quit
```

O usar el modo de prueba integrado:

```bash
sudo plymouth-set-default-theme --test spinner
```

---

## 5. Verificación tras reinicio

Tras reiniciar, confirmar que el initramfs tiene el tema correcto:

```bash
lsinitramfs /boot/initrd.img-$(uname -r) | grep plymouth
```

Debe aparecer el theme elegido en la lista de archivos incluidos.

---

## Notas

- El splash screen opera a resolución de framebuffer (no a los 2560×1600 nativos)
  hasta que GDM toma el control. Esto es normal con NVIDIA propietario.
- Si aparece pantalla negra prolongada durante el arranque, añadir a
  `GRUB_CMDLINE_LINUX_DEFAULT` en `/etc/default/grub`:
  ```
  plymouth.ignore-serial-consoles
  ```
  Y luego `sudo update-grub`.
- Para depurar el arranque temporalmente, usar el tema `details` que muestra
  salida de texto completa del kernel.
- `update-initramfs -u` tarda ~30 segundos; es normal.
- El tema `bgrt` lee el logo directamente de la tabla ACPI del firmware Razer,
  por eso la calidad es superior a los temas que usan imágenes estáticas.

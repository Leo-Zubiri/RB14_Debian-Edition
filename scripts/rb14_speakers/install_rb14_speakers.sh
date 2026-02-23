#!/bin/bash
# ============================================================
# Razer Blade 14 2023 - Instalador del servicio de bocinas internas
# ============================================================
# Uso:
#   sudo bash install_rb14_speakers.sh install
#   sudo bash install_rb14_speakers.sh uninstall
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/RB14_2023_enable_internal_speakers_ver2.sh"

SERVICE_NAME="rb14-speakers"
INSTALL_DIR="/usr/local/lib/rb14-speakers"
INSTALLED_SCRIPT="$INSTALL_DIR/fix.sh"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
# Detectar ruta correcta del directorio system-sleep según la distro
if [[ -d "/usr/lib/systemd/system-sleep" ]]; then
    SLEEP_HOOK="/usr/lib/systemd/system-sleep/${SERVICE_NAME}"
else
    SLEEP_HOOK="/lib/systemd/system-sleep/${SERVICE_NAME}"
fi

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Este script debe ejecutarse como root."
        echo "       Usa: sudo bash $0 ${1:-install}"
        exit 1
    fi
}

install_alsa_tools() {
    if command -v apt-get &>/dev/null; then
        apt-get update -qq && apt-get install -y alsa-tools
    elif command -v dnf &>/dev/null; then
        dnf install -y alsa-tools
    elif command -v yum &>/dev/null; then
        yum install -y alsa-tools
    elif command -v pacman &>/dev/null; then
        pacman -Sy --noconfirm alsa-tools
    elif command -v zypper &>/dev/null; then
        zypper install -y alsa-tools
    elif command -v emerge &>/dev/null; then
        emerge media-sound/alsa-tools
    else
        echo "ERROR: No se reconoció ningún gestor de paquetes."
        echo "       Instala 'alsa-tools' manualmente y vuelve a ejecutar este script."
        exit 1
    fi
}

check_dependencies() {
    if ! command -v hda-verb &>/dev/null; then
        echo ">>> hda-verb no encontrado. Instalando alsa-tools..."
        install_alsa_tools
        echo ">>> alsa-tools instalado."
    else
        echo ">>> hda-verb encontrado: $(command -v hda-verb)"
    fi
}

# ------------------------------------------------------------
# Instalar
# ------------------------------------------------------------

do_install() {
    check_root "install"
    check_dependencies

    if [[ ! -f "$SOURCE_SCRIPT" ]]; then
        echo "ERROR: No se encontró el script original en:"
        echo "       $SOURCE_SCRIPT"
        echo "       Asegúrate de ejecutar este instalador desde el mismo directorio."
        exit 1
    fi

    echo ""
    echo ">>> Creando directorio de instalación: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    echo ">>> Copiando script de corrección de audio..."
    cp "$SOURCE_SCRIPT" "$INSTALLED_SCRIPT"
    chmod 755 "$INSTALLED_SCRIPT"

    echo ">>> Creando unidad systemd: $SERVICE_FILE"
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Razer Blade 14 2023 - Bocinas internas (HDA codec fix)
Documentation=https://github.com/search?q=Razer+Blade+14+2023+speakers
After=sound.target
Wants=sound.target

[Service]
Type=oneshot
# Espera a que todos los dispositivos de audio estén listos
ExecStartPre=/usr/bin/udevadm settle
# Delay adicional para que el codec HDA esté completamente inicializado
ExecStartPre=/bin/sleep 5
ExecStart=/bin/bash $INSTALLED_SCRIPT
# Mantiene el servicio como "activo" para que systemctl status lo muestre correctamente
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    echo ">>> Creando hook para suspensión/reanudación: $SLEEP_HOOK"
    cat > "$SLEEP_HOOK" <<'HOOKEOF'
#!/bin/bash
# Hook de systemd-sleep para Razer Blade 14 2023 - bocinas internas
# Se ejecuta antes y después de suspender/hibernar.
# $1 = pre | post
# $2 = suspend | hibernate | hybrid-sleep | suspend-then-hibernate

case "$1/$2" in
    post/*)
        # Después de salir de suspensión, el codec queda sin inicializar.
        # Re-ejecutamos la corrección de audio.
        /bin/bash /usr/local/lib/rb14-speakers/fix.sh
        ;;
esac
HOOKEOF
    chmod 755 "$SLEEP_HOOK"

    echo ">>> Recargando systemd..."
    systemctl daemon-reload

    echo ">>> Habilitando servicio (arranque automático)..."
    systemctl enable "${SERVICE_NAME}.service"

    echo ">>> Iniciando servicio ahora..."
    systemctl start "${SERVICE_NAME}.service"

    echo ""
    echo "============================================================"
    echo " Instalación completada exitosamente."
    echo "============================================================"
    echo ""
    echo "Estado actual del servicio:"
    systemctl status "${SERVICE_NAME}.service" --no-pager -l || true
    echo ""
    echo "Las bocinas se activarán automáticamente en cada arranque"
    echo "y después de cada suspensión/hibernación."
}

# ------------------------------------------------------------
# Desinstalar
# ------------------------------------------------------------

do_uninstall() {
    check_root "uninstall"

    echo ">>> Deteniendo el servicio..."
    systemctl stop "${SERVICE_NAME}.service" 2>/dev/null || true

    echo ">>> Deshabilitando el servicio (arranque automático)..."
    systemctl disable "${SERVICE_NAME}.service" 2>/dev/null || true

    echo ">>> Eliminando archivos del servicio..."
    rm -f "$SERVICE_FILE"
    rm -f "$SLEEP_HOOK"
    rm -rf "$INSTALL_DIR"

    echo ">>> Recargando systemd..."
    systemctl daemon-reload
    systemctl reset-failed 2>/dev/null || true

    echo ""
    echo "============================================================"
    echo " Desinstalación completada."
    echo " El script de audio ya NO se ejecutará automáticamente."
    echo "============================================================"
}

# ------------------------------------------------------------
# Punto de entrada
# ------------------------------------------------------------

case "${1:-}" in
    install)
        do_install
        ;;
    uninstall)
        do_uninstall
        ;;
    *)
        echo "Uso: sudo bash $(basename "$0") [install|uninstall]"
        echo ""
        echo "  install    Instala el servicio systemd para activar las bocinas en"
        echo "             cada arranque y después de suspender/hibernar."
        echo "  uninstall  Elimina el servicio y todos los archivos instalados."
        echo ""
        exit 1
        ;;
esac

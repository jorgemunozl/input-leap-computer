#!/usr/bin/env bash
# inputleap-setup.sh
# Interactivo: genera config de Input Leap (server/client) y opcionalmente systemd.
set -euo pipefail

# ---------- Helpers ----------
say() { printf "\033[1;32m[*]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[x]\033[0m %s\n" "$*" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---------- Pre-flight ----------
if ! has_cmd input-leapc || ! has_cmd input-leaps; then
  err "No encuentro 'input-leapc' y/o 'input-leaps' en PATH. Instala Input Leap primero."
  err "En Flatpak, puedes usar: flatpak run --command=input-leaps io.github.input_leap.InputLeap"
  exit 1
fi

# XDG base dir (config)
XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
IL_DIR="$XDG_CFG/InputLeap"
CFG_FILE="$IL_DIR/InputLeap.conf"
SSL_DIR="$IL_DIR/SSL"
FP_DIR="$SSL_DIR/Fingerprints"

mkdir -p "$IL_DIR" "$FP_DIR"

say "¿Rol de esta máquina? [s=server / c=client]"
read -r ROLE
ROLE="${ROLE:-s}"

# ---------- Common questions ----------
HOST_DEFAULT="$(hostname)"
say "Nombre de pantalla local (screen name) [$HOST_DEFAULT]:"
read -r SCREEN_NAME
SCREEN_NAME="${SCREEN_NAME:-$HOST_DEFAULT}"

# ---------- Server path ----------
if [[ "$ROLE" =~ ^[Ss]$ ]]; then
  say "Configurar SERVER (input-leaps)."

  # Pantallas y layout
  say "Ingresa el nombre de la pantalla CLIENT (por ejemplo: laptop-de-jorge):"
  read -r CLIENT_NAME
  CLIENT_NAME="${CLIENT_NAME:-client1}"

  say "¿Dónde está el CLIENT respecto a esta máquina SERVER?"
  say "Opciones: left/right/up/down (ej. 'right' = el cliente está a la derecha del server)"
  read -r DIR
  DIR="${DIR:-right}"

  # Opciones
  say "¿Habilitar arrastre de archivos (drag & drop)? [Y/n]"
  read -r DRAG
  DRAG="${DRAG:-Y}"

  say "¿Requerir cifrado/SSL? (puedes gestionarlo luego) [y/N]"
  read -r WANT_SSL
  WANT_SSL="${WANT_SSL:-N}"

  # Construir config
  cat >"$CFG_FILE" <<EOF
# Input Leap server configuration
# Formato heredado de Synergy/Barrier: sections screens/aliases/links/options
# https://github.com/input-leap/input-leap/wiki/Command-Line

section: screens
    ${SCREEN_NAME}:
    ${CLIENT_NAME}:
end

section: aliases
    ${SCREEN_NAME}:
    ${SCREEN_NAME}.local
    ${SCREEN_NAME}.lan
    ${HOST_DEFAULT}
end

section: links
    ${SCREEN_NAME}:
        ${DIR} = ${CLIENT_NAME}
    ${CLIENT_NAME}:
        $( [[ "$DIR" == "right" ]] && echo "left" || \
            [[ "$DIR" == "left"  ]] && echo "right" || \
            [[ "$DIR" == "up"    ]] && echo "down"  || \
            [[ "$DIR" == "down"  ]] && echo "up" ) = ${SCREEN_NAME}
end

section: options
    keystroke(Control+Alt+BackTick) = switchToScreen(${SCREEN_NAME})
    keystroke(Control+Alt+BackSlash) = switchToScreen(${CLIENT_NAME})
    $( [[ "$DRAG" =~ ^[Yy]$ ]] && echo "enableDragDrop = true" )
end
EOF

  say "Config del server escrita en: $CFG_FILE"

  # SSL scaffolding opcional
  if [[ "$WANT_SSL" =~ ^[Yy]$ ]]; then
    touch "$SSL_DIR/Input Leap.pem" "$FP_DIR/Local.txt"
    mkdir -p "$FP_DIR"
    say "Estructura SSL preparada en: $SSL_DIR (recuerda generar/cargar certificado y fingerprints)."
    warn "Puedes usar GUI de Input Leap para generarlos o 'openssl' manualmente."
  fi

  # ¿Crear servicio systemd?
  say "¿Crear servicio systemd para el SERVER? [y/N]"
  read -r WANT_SVC
  WANT_SVC="${WANT_SVC:-N}"
  if [[ "$WANT_SVC" =~ ^[Yy]$ ]]; then
    UNIT="/etc/systemd/system/input-leap-server.service"
    SUDO="${SUDO:-sudo}"
    $SUDO bash -c "cat >'$UNIT' <<SVC
[Unit]
Description=Input Leap Server
After=network.target

[Service]
User=$USER
Group=$(id -gn)
ExecStart=$(command -v input-leaps) --debug INFO --disable-crypto -f --name ${SCREEN_NAME} --config $CFG_FILE
Restart=always

[Install]
WantedBy=multi-user.target
SVC"
    $SUDO systemctl daemon-reload
    $SUDO systemctl enable --now input-leap-server.service
    say "Servicio systemd del SERVER habilitado."
  fi

  say "Para iniciar manualmente:"
  echo "  input-leaps --name ${SCREEN_NAME} --config \"$CFG_FILE\" --debug INFO --disable-crypto -f"

# ---------- Client path ----------
else
  say "Configurar CLIENT (input-leapc)."

  say "IP o hostname del SERVER (ej. 192.168.1.10):"
  read -r SERVER_HOST
  SERVER_HOST="${SERVER_HOST:-127.0.0.1}"

  say "¿Quisieras guardar un perfil dedicado (profile-dir) para logs/SSL? [Y/n]"
  read -r WANT_PROFILE
  WANT_PROFILE="${WANT_PROFILE:-Y}"

  CLIENT_PROFILE="$IL_DIR"
  if [[ "$WANT_PROFILE" =~ ^[Yy]$ ]]; then
    CLIENT_PROFILE="$IL_DIR"
    mkdir -p "$CLIENT_PROFILE"
  fi

  # SSL fingerprints (opcional)
  mkdir -p "$FP_DIR"
  touch "$FP_DIR/TrustedServers.txt" || true

  say "Comando para iniciar el CLIENT (ejecútalo tras el server):"
  echo "  input-leapc --name ${SCREEN_NAME} --profile-dir \"$CLIENT_PROFILE\" --debug INFO --disable-crypto -f ${SERVER_HOST}"

  # ¿Crear servicio systemd?
  say "¿Crear servicio systemd para el CLIENT? [y/N]"
  read -r WANT_SVC
  WANT_SVC="${WANT_SVC:-N}"
  if [[ "$WANT_SVC" =~ ^[Yy]$ ]]; then
    UNIT="/etc/systemd/system/input-leap-client.service"
    SUDO="${SUDO:-sudo}"
    $SUDO bash -c "cat >'$UNIT' <<SVC
[Unit]
Description=Input Leap Client
After=network.target

[Service]
User=$USER
Group=$(id -gn)
ExecStart=$(command -v input-leapc) --enable-drag-drop --debug INFO --disable-crypto -f --name ${SCREEN_NAME} --profile-dir $CLIENT_PROFILE ${SERVER_HOST}
Restart=always

[Install]
WantedBy=multi-user.target
SVC"
    $SUDO systemctl daemon-reload
    $SUDO systemctl enable --now input-leap-client.service
    say "Servicio systemd del CLIENT habilitado."
  fi
fi

say "Listo."

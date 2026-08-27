#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

HL_VERSION="1.2.2"
REPO_URL="https://github.com/Cylne/HermesLaunch.git"
HERMES_INSTALL_URL="https://hermes-agent.nousresearch.com/install.sh"
SESSION_NAME="hermeslaunch-gateway"
LOG_FILE="${HOME}/.hermes/logs/hermeslaunch-termux-gateway.log"

C_RESET='\033[0m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_BOLD='\033[1m'

info(){ printf "${C_BLUE}[HermesLaunch]${C_RESET} %s\n" "$*"; }
ok(){ printf "${C_GREEN}[✓]${C_RESET} %s\n" "$*"; }
warn(){ printf "${C_YELLOW}[!]${C_RESET} %s\n" "$*" >&2; }
die(){ printf "${C_RED}[✗]${C_RESET} %s\n" "$*" >&2; exit 1; }

banner() {
  printf "${C_BOLD}${C_BLUE}"
  cat <<'EOF'
╭──────────────────────────────────────────────╮
│               HermesLaunch                   │
│            Termux Mobile Mode                │
│                                              │
│               Created by Reii                │
╰──────────────────────────────────────────────╯
EOF
  printf "${C_RESET}"
  printf "Version %s\n\n" "$HL_VERSION"
}

is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == *"com.termux"* ]] || [[ "$(uname -o 2>/dev/null || true)" == "Android" ]]
}

install_manager() {
  mkdir -p "$PREFIX/bin"
  cat > "$PREFIX/bin/hermeslaunch" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

SESSION_NAME="hermeslaunch-gateway"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
LOG_FILE="$HERMES_HOME/logs/hermeslaunch-termux-gateway.log"
export HERMES_HOME
export PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"

HERMES="$(command -v hermes 2>/dev/null || true)"
[[ -n "$HERMES" ]] || { echo "Hermes tidak ditemukan."; exit 1; }

start_gateway() {
  mkdir -p "$HERMES_HOME/logs"
  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Hermes Gateway sudah berjalan."
    return 0
  fi

  if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock || true
  fi

  tmux new-session -d -s "$SESSION_NAME" \
    "exec '$HERMES' gateway run >> '$LOG_FILE' 2>&1"

  sleep 2
  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Hermes Gateway aktif di Termux (best-effort background)."
  else
    echo "Gateway gagal start. Jalankan: hermeslaunch logs"
    exit 1
  fi
}

stop_gateway() {
  tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
  if command -v termux-wake-unlock >/dev/null 2>&1; then
    termux-wake-unlock || true
  fi
  echo "Hermes Gateway dihentikan."
}

case "${1:-status}" in
  start)
    start_gateway
    ;;
  stop)
    stop_gateway
    ;;
  restart)
    stop_gateway
    start_gateway
    ;;
  status)
    echo "HermesLaunch Mode: Termux Mobile"
    echo "Runtime: tmux + hermes gateway run"
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "Gateway: running"
      echo "tmux session: $SESSION_NAME"
    else
      echo "Gateway: stopped"
    fi
    ;;
  logs)
    mkdir -p "$HERMES_HOME/logs"
    touch "$LOG_FILE"
    tail -f "$LOG_FILE"
    ;;
  doctor)
    "$HERMES" doctor
    ;;
  model)
    "$HERMES" model
    ;;
  gateway-setup)
    "$HERMES" gateway setup
    ;;
  backup)
    out="${2:-$HOME/hermes-backup-$(date +%Y%m%d-%H%M%S).zip}"
    "$HERMES" backup -o "$out"
    chmod 600 "$out" 2>/dev/null || true
    echo "Backup: $out"
    echo "PERINGATAN: full backup Hermes berisi credential."
    ;;
  restore)
    file="${2:-}"
    [[ -n "$file" && -f "$file" ]] || { echo "Usage: hermeslaunch restore <backup.zip>"; exit 2; }
    stop_gateway
    "$HERMES" import "$file" --force
    chmod 600 "$HERMES_HOME/.env" 2>/dev/null || true
    start_gateway
    ;;
  update)
    "$HERMES" update --backup
    ;;
  version)
    echo "HermesLaunch v1.2.2 — Termux Mobile Mode"
    "$HERMES" --version
    ;;
  *)
    cat <<'HELP'
HermesLaunch — Termux Mobile Mode
Created by Reii

Commands:
  hermeslaunch status
  hermeslaunch start
  hermeslaunch stop
  hermeslaunch restart
  hermeslaunch logs
  hermeslaunch doctor
  hermeslaunch model
  hermeslaunch gateway-setup
  hermeslaunch backup [file.zip]
  hermeslaunch restore <file.zip>
  hermeslaunch update
  hermeslaunch version
HELP
    ;;
esac
EOF
  chmod 755 "$PREFIX/bin/hermeslaunch"
}

setup_boot_helper() {
  printf "Buat helper Termux:Boot? (tetap butuh aplikasi Termux:Boot) [y/N]: " > /dev/tty
  read -r ans < /dev/tty || true
  if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/.termux/boot"
    cat > "$HOME/.termux/boot/hermeslaunch-gateway.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
sleep 15
command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock || true
hermeslaunch start
EOF
    chmod 700 "$HOME/.termux/boot/hermeslaunch-gateway.sh"
    ok "Helper Termux:Boot dibuat."
  fi
}

main() {
  banner
  is_termux || die "Script ini khusus Android Termux. Untuk VPS gunakan install-vps.sh."

  info "Repository: $REPO_URL"
  warn "Termux adalah Tier-2/best-effort. Android dapat menghentikan background process."
  echo

  cat <<'GUIDE'
Sebelum wizard dimulai, siapkan:

[Telegram]
  Bot Token
    → dari @BotFather

  Numeric User ID
    → dari @userinfobot / @get_id_bot
    → contoh: 1447854280
    → bukan @username

  Home Channel
    → DM pribadi: gunakan User ID kamu
    → grup/forum: gunakan Chat ID seperti -1001234567890
    → bisa diganti nanti dengan /sethome

[AI Provider]
  API Base URL → contoh https://provider.example.com/v1
  API Key      → dari dashboard provider
  Model ID     → ID model persis dari provider

Jika wizard menampilkan [nilai-default], tekan Enter untuk memakai nilai tersebut.
GUIDE
  echo

  pkg update -y
  pkg install -y git curl tmux

  NEED_MODEL_SETUP=1
  if ! command -v hermes >/dev/null 2>&1; then
    info "Menginstall Hermes menggunakan installer resmi yang Termux-aware..."
    installer_tmp="$(mktemp)"
    curl -fsSL "$HERMES_INSTALL_URL" -o "$installer_tmp"

    installer_help="$(bash "$installer_tmp" --help 2>&1 || true)"
    if grep -q -- '--skip-setup' <<<"$installer_help"; then
      bash "$installer_tmp" --skip-setup
      NEED_MODEL_SETUP=1
    else
      warn "Installer Hermes tidak mengiklankan --skip-setup; setup model resmi akan berjalan saat instalasi."
      bash "$installer_tmp"
      NEED_MODEL_SETUP=0
    fi

    rm -f "$installer_tmp"
    export PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"
  else
    ok "Hermes sudah terinstall."
  fi

  command -v hermes >/dev/null 2>&1 || die "Command hermes belum ditemukan. Buka ulang Termux lalu coba lagi."

  if [[ "$NEED_MODEL_SETUP" == 1 ]]; then
    echo
    info "Konfigurasi model/provider Hermes."
    echo "Wizard berikut adalah wizard resmi Hermes."
    hermes model
  fi

  echo
  info "Konfigurasi Telegram Gateway."
  echo "Pilih Telegram, masukkan Bot Token dan numeric Telegram User ID."
  hermes gateway setup

  install_manager
  setup_boot_helper

  mkdir -p "$HOME/Reii" "$HOME/.hermes/logs"
  hermeslaunch start

  echo
  ok "HermesLaunch Termux Mode selesai."
  echo "Workspace default: $HOME/Reii"
  echo "Status: hermeslaunch status"
  echo "Logs  : hermeslaunch logs"
  echo
  warn "Termux Mode bukan pengganti systemd VPS. Untuk uptime 24/7 yang stabil, gunakan VPS Mode."
}

main "$@"

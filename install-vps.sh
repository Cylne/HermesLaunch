#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

HL_VERSION="1.2.1"
HERMES_INSTALL_URL="https://hermes-agent.nousresearch.com/install.sh"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

C_RESET='\033[0m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_BOLD='\033[1m'

info(){ printf "${C_CYAN}●${C_RESET} %s\n" "$*"; }
ok(){ printf "${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn(){ printf "${C_YELLOW}!${C_RESET} %s\n" "$*" >&2; }
die(){ printf "${C_RED}✗${C_RESET} %s\n" "$*" >&2; exit 1; }

banner() {
  printf "${C_BOLD}${C_BLUE}"
  cat <<'EOF'
╭──────────────────────────────────────────────╮
│               HermesLaunch                   │
│     VPS Deployment & Management Toolkit      │
│                                              │
│               Created by Reii                │
╰──────────────────────────────────────────────╯
EOF
  printf "${C_RESET}"
  printf "Version %s\n\n" "$HL_VERSION"
}

is_termux() {
  [[ "${PREFIX:-}" == *"com.termux"* ]] || [[ "$(uname -o 2>/dev/null || true)" == "Android" ]]
}

termux_notice() {
cat <<'EOF'
HermesLaunch v1.2.1 ditujukan untuk VPS Linux + systemd.

Kamu sedang menjalankannya di Termux Android.
Gunakan Termux sebagai SSH client:

  pkg update -y
  pkg install -y openssh curl
  ssh root@IP_VPS

Setelah masuk ke VPS, jalankan installer HermesLaunch di sana.

Panduan lengkap:
  docs/TERMUX.md

Catatan: Hermes Agent sendiri punya dukungan Termux Tier 2, tetapi deployment
HermesLaunch ini fokus pada VPS 24/7 agar gateway Telegram stabil.
EOF
}

need_tty() {
  [[ -r /dev/tty && -w /dev/tty ]] || die "Wizard membutuhkan TTY. Login SSH biasa lalu jalankan lagi."
}

ask() {
  local __var="$1" prompt="$2" default="${3:-}" value=""
  if [[ -n "$default" ]]; then
    printf "%s [%s]: " "$prompt" "$default" > /dev/tty
  else
    printf "%s: " "$prompt" > /dev/tty
  fi
  IFS= read -r value < /dev/tty || true
  [[ -z "$value" ]] && value="$default"
  printf -v "$__var" '%s' "$value"
}

ask_secret() {
  local __var="$1" prompt="$2" value=""
  printf "%s: " "$prompt" > /dev/tty
  IFS= read -r -s value < /dev/tty || true
  printf "\n" > /dev/tty
  printf -v "$__var" '%s' "$value"
}

confirm() {
  local prompt="$1" default="${2:-Y}" answer=""
  if [[ "$default" == "Y" ]]; then
    printf "%s [Y/n]: " "$prompt" > /dev/tty
  else
    printf "%s [y/N]: " "$prompt" > /dev/tty
  fi
  IFS= read -r answer < /dev/tty || true
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[Yy]$ ]]
}

setup_privileges() {
  TARGET_USER="$(id -un)"
  TARGET_HOME="$HOME"
  if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
  else
    command -v sudo >/dev/null 2>&1 || die "Butuh sudo/root untuk memasang system service."
    SUDO="sudo"
  fi
}

check_platform() {
  [[ "$(uname -s)" == "Linux" ]] || die "HermesLaunch v1.2.1 hanya mendukung Linux VPS."
  command -v systemctl >/dev/null 2>&1 || die "systemd tidak ditemukan. HermesLaunch v1.2.1 membutuhkan systemd."
  if is_termux; then
    termux_notice
    exit 2
  fi
}

install_prereqs() {
  info "Memeriksa dependency dasar..."
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -y
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y \
      ca-certificates curl git unzip zip
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y ca-certificates curl git unzip zip
  elif command -v yum >/dev/null 2>&1; then
    $SUDO yum install -y ca-certificates curl git unzip zip
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Sy --noconfirm ca-certificates curl git unzip zip
  else
    warn "Package manager tidak dikenali. Melanjutkan jika curl/git sudah tersedia."
  fi
  command -v curl >/dev/null 2>&1 || die "curl belum tersedia."
  command -v git >/dev/null 2>&1 || die "git belum tersedia."
  ok "Dependency dasar siap"
}

find_hermes() {
  export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
  HERMES_BIN="$(command -v hermes 2>/dev/null || true)"
  [[ -n "$HERMES_BIN" ]]
}

install_hermes() {
  if find_hermes; then
    ok "Hermes sudah terpasang: $HERMES_BIN"
    return
  fi

  info "Menginstall Hermes Agent dari installer resmi..."
  local tmp
  tmp="$(mktemp)"
  curl -fsSL "$HERMES_INSTALL_URL" -o "$tmp"

  if [[ "${HERMESLAUNCH_WITH_BROWSER:-0}" == "1" ]]; then
    bash "$tmp" --skip-setup
  else
    bash "$tmp" --skip-setup --skip-browser
  fi
  rm -f "$tmp"

  export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
  find_hermes || die "Hermes selesai diinstall tetapi command 'hermes' belum ditemukan."
  ok "Hermes berhasil terinstall"
}

backup_existing() {
  mkdir -p "$HERMES_HOME"
  chmod 700 "$HERMES_HOME" || true
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"

  if [[ -f "$HERMES_HOME/config.yaml" ]]; then
    cp -a "$HERMES_HOME/config.yaml" "$HERMES_HOME/config.yaml.pre-hermeslaunch-$ts"
    ok "Backup config.yaml dibuat"
  fi
  if [[ -f "$HERMES_HOME/.env" ]]; then
    cp -a "$HERMES_HOME/.env" "$HERMES_HOME/.env.pre-hermeslaunch-$ts"
    chmod 600 "$HERMES_HOME/.env.pre-hermeslaunch-$ts" || true
    ok "Backup .env dibuat"
  fi
}

safe_slug() {
  local raw="$1"
  raw="${raw,,}"
  raw="$(printf '%s' "$raw" | tr -cs 'a-z0-9_-' '-' | sed 's/^-*//;s/-*$//')"
  [[ -n "$raw" ]] || raw="mainapi"
  printf '%s' "${raw:0:48}"
}

env_key_for() {
  local s
  s="$(printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_')"
  s="$(printf '%s' "$s" | tr -cd 'A-Z0-9_')"
  printf 'HERMESLAUNCH_%s_API_KEY' "$s"
}

dotenv_set() {
  local key="$1" value="$2"
  [[ "$value" != *$'\n'* && "$value" != *$'\r'* ]] || die "Secret mengandung newline."
  mkdir -p "$HERMES_HOME"
  touch "$HERMES_HOME/.env"
  chmod 600 "$HERMES_HOME/.env"

  KEY="$key" VALUE="$value" FILE="$HERMES_HOME/.env" python3 - <<'PY'
import json, os, re
from pathlib import Path
p=Path(os.environ["FILE"])
key=os.environ["KEY"]
value=os.environ["VALUE"]
lines=p.read_text(encoding="utf-8").splitlines() if p.exists() else []
pat=re.compile(r"^\s*"+re.escape(key)+r"\s*=")
line=f"{key}={json.dumps(value, ensure_ascii=False)}"
out=[]
done=False
for old in lines:
    if pat.match(old):
        if not done:
            out.append(line); done=True
    else:
        out.append(old)
if not done:
    out.append(line)
p.write_text("\n".join(out).rstrip()+"\n", encoding="utf-8")
PY
  chmod 600 "$HERMES_HOME/.env"
}

ensure_python() {
  if command -v python3 >/dev/null 2>&1; then
    return
  fi
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get install -y python3
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y python3
  elif command -v yum >/dev/null 2>&1; then
    $SUDO yum install -y python3
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -S --noconfirm python
  else
    die "python3 dibutuhkan untuk penyimpanan secret yang aman."
  fi
}

discover_models() {
  local url="${PROVIDER_URL%/}/models"
  local result=""
  result="$(
    HL_URL="$url" HL_KEY="$PROVIDER_KEY" python3 - <<'PY' 2>/dev/null || true
import json, os, urllib.request
url=os.environ["HL_URL"]
key=os.environ.get("HL_KEY","")
req=urllib.request.Request(url)
if key:
    req.add_header("Authorization", "Bearer "+key)
req.add_header("Accept","application/json")
try:
    with urllib.request.urlopen(req, timeout=15) as r:
        data=json.load(r)
    rows=data.get("data", data if isinstance(data,list) else [])
    ids=[]
    for item in rows:
        if isinstance(item,dict) and item.get("id"):
            ids.append(str(item["id"]))
        elif isinstance(item,str):
            ids.append(item)
    for x in ids[:25]:
        print(x)
except Exception:
    pass
PY
  )"

  if [[ -n "$result" ]]; then
    printf "\n${C_BOLD}Model yang terdeteksi (maks. 25):${C_RESET}\n" > /dev/tty
    printf '%s\n' "$result" | nl -w2 -s'. ' > /dev/tty
    printf "\n" > /dev/tty
    return 0
  fi
  warn "Tidak bisa membaca /models. Kamu tetap bisa memasukkan Model ID manual."
  return 1
}

wizard() {
  need_tty
  printf "\n${C_BOLD}1/3 — Telegram${C_RESET}\n" > /dev/tty
  printf "${C_CYAN}ℹ Panduan Telegram:${C_RESET}\n" > /dev/tty
  printf "  • Bot Token = token bot dari @BotFather.\n" > /dev/tty
  printf "    Contoh format: 123456789:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n" > /dev/tty
  printf "  • Numeric User ID = ID angka akun Telegram yang boleh memakai bot.\n" > /dev/tty
  printf "    Ambil dari @userinfobot / @get_id_bot. BUKAN @username.\n" > /dev/tty
  printf "  • Home Channel = chat default untuk cron/notifikasi Hermes.\n" > /dev/tty
  printf "    Bot pribadi: cukup tekan Enter agar memakai User ID utama.\n" > /dev/tty
  printf "    Grup/forum: isi Chat ID grup, biasanya -100xxxxxxxxxx.\n\n" > /dev/tty

  ask_secret TELEGRAM_TOKEN "Bot Token dari @BotFather"
  [[ -n "$TELEGRAM_TOKEN" ]] || die "Bot Token wajib diisi."

  ask TELEGRAM_USERS "Telegram numeric User ID (contoh 1447854280; multi-user: 111,222)" ""
  [[ "$TELEGRAM_USERS" =~ ^[0-9]+(,[0-9]+)*$ ]] || die "Telegram User ID harus berupa angka. Jangan gunakan @username."
  local first_user="${TELEGRAM_USERS%%,*}"

  printf "\n${C_CYAN}Home Channel${C_RESET} = tujuan default cron/notifikasi.\n" > /dev/tty
  printf "Kalau ingin masuk ke DM akun utama (%s), cukup tekan Enter.\n" "$first_user" > /dev/tty
  ask TELEGRAM_HOME "Home Channel Chat ID" "$first_user"

  if [[ "$TELEGRAM_HOME" == "ID" || "$TELEGRAM_HOME" == "id" ]]; then
    warn "Literal 'ID' bukan Chat ID. Otomatis memakai default $first_user."
    TELEGRAM_HOME="$first_user"
  fi
  [[ "$TELEGRAM_HOME" =~ ^-?[0-9]+$ ]] || die "Home Channel harus Chat ID angka, misalnya $first_user atau -1001234567890."

  printf "\n${C_BOLD}2/3 — AI Provider${C_RESET}\n" > /dev/tty
  printf "${C_CYAN}ℹ Panduan Provider:${C_RESET}\n" > /dev/tty
  printf "  • Nama provider = label bebas, contoh GodenAPI / OpenRouter / 9Router.\n" > /dev/tty
  printf "  • API Base URL = endpoint provider, biasanya berakhiran /v1.\n" > /dev/tty
  printf "  • API Key = key rahasia dari dashboard provider.\n" > /dev/tty
  printf "  • Compatibility = mayoritas OpenAI-compatible pilih 1.\n" > /dev/tty
  printf "  • Model ID = ID model persis dari provider.\n" > /dev/tty
  printf "  • Context Length = kalau tidak tahu, tekan Enter.\n\n" > /dev/tty

  ask PROVIDER_NAME "Nama provider (contoh GodenAPI)" "MainAPI"
  ask PROVIDER_URL "API Base URL (contoh https://api.example.com/v1)" ""

  [[ "$PROVIDER_URL" =~ ^https?:// ]] || die "Base URL wajib diawali https:// atau http://"
  if [[ "$PROVIDER_URL" =~ ^http:// ]] && [[ ! "$PROVIDER_URL" =~ ^http://(127\.0\.0\.1|localhost)(:|/) ]]; then
    die "Endpoint remote HTTP ditolak. Gunakan HTTPS. HTTP hanya boleh untuk localhost."
  fi

  ask_secret PROVIDER_KEY "API Key (Enter hanya jika endpoint lokal/keyless)"

  printf "\nAPI Compatibility:\n" > /dev/tty
  printf "  1. Chat Completions (OpenAI-compatible) [paling umum / default]\n" > /dev/tty
  printf "  2. Responses / Codex\n" > /dev/tty
  printf "  3. Anthropic Messages\n" > /dev/tty
  printf "  Tidak tahu? Tekan Enter untuk pilihan 1.\n" > /dev/tty
  ask MODE_CHOICE "Pilih [1-3]" "1"
  case "$MODE_CHOICE" in
    1) TRANSPORT="chat_completions" ;;
    2) TRANSPORT="codex_responses" ;;
    3) TRANSPORT="anthropic_messages" ;;
    *) die "Pilihan compatibility mode tidak valid." ;;
  esac

  if confirm "Coba ambil daftar model dari /models?" "Y"; then
    discover_models || true
  fi

  printf "\n${C_CYAN}Model ID${C_RESET}: gunakan ID persis dari provider/daftar model.\n" > /dev/tty
  ask MODEL_ID "Model ID yang akan dijadikan default" ""
  [[ -n "$MODEL_ID" ]] || die "Model ID wajib diisi."

  printf "${C_CYAN}Context Length${C_RESET}: opsional; kalau tidak tahu cukup tekan Enter.\n" > /dev/tty
  ask CONTEXT_LENGTH "Context length token (Enter = default/auto)" ""
  if [[ -n "$CONTEXT_LENGTH" ]]; then
    [[ "$CONTEXT_LENGTH" =~ ^[0-9]+$ ]] || die "Context length harus angka."
    if (( CONTEXT_LENGTH < 64000 )); then
      warn "Hermes merekomendasikan context window minimal sekitar 64K untuk agentic workflow."
    fi
  fi

  printf "\n${C_BOLD}3/3 — Workspace${C_RESET}\n" > /dev/tty
  printf "${C_CYAN}ℹ Workspace${C_RESET} = folder default tempat Hermes mengerjakan/menyimpan project.\n" > /dev/tty
  printf "Kalau tidak punya folder khusus, cukup tekan Enter.\n" > /dev/tty
  ask WORKSPACE "Folder project default" "$HOME/Reii"

  if confirm "Tes satu prompt AI setelah setup? Ini memakai sedikit quota/token." "Y"; then
    TEST_CHAT="1"
  else
    TEST_CHAT="0"
  fi
}

configure_telegram() {
  info "Mengkonfigurasi Telegram..."
  dotenv_set "TELEGRAM_BOT_TOKEN" "$TELEGRAM_TOKEN"
  dotenv_set "TELEGRAM_ALLOWED_USERS" "$TELEGRAM_USERS"
  dotenv_set "TELEGRAM_HOME_CHANNEL" "$TELEGRAM_HOME"
  dotenv_set "TELEGRAM_HOME_CHANNEL_NAME" "HermesLaunch Telegram"
  ok "Telegram token + allowlist tersimpan"
}

configure_provider() {
  info "Mengkonfigurasi custom provider..."
  PROVIDER_SLUG="$(safe_slug "$PROVIDER_NAME")"
  PROVIDER_KEY_ENV="$(env_key_for "$PROVIDER_SLUG")"

  if [[ -n "$PROVIDER_KEY" ]]; then
    dotenv_set "$PROVIDER_KEY_ENV" "$PROVIDER_KEY"
  else
    dotenv_set "$PROVIDER_KEY_ENV" "no-key-required"
  fi

  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.api" "$PROVIDER_URL"
  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.name" "$PROVIDER_NAME"
  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.key_env" "$PROVIDER_KEY_ENV"
  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.transport" "$TRANSPORT"
  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.default_model" "$MODEL_ID"
  "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.discover_models" "true"

  if [[ -n "$CONTEXT_LENGTH" ]]; then
    "$HERMES_BIN" config set "providers.${PROVIDER_SLUG}.context_length" "$CONTEXT_LENGTH"
  fi

  "$HERMES_BIN" config set "model.provider" "custom:${PROVIDER_SLUG}"
  "$HERMES_BIN" config set "model.default" "$MODEL_ID"

  ok "Provider custom:${PROVIDER_SLUG} aktif"
}

configure_workspace() {
  mkdir -p "$WORKSPACE"
  chmod 700 "$WORKSPACE" 2>/dev/null || true
  cat > "$WORKSPACE/AGENTS.md" <<EOF
# HermesLaunch Workspace

Default workspace managed for this Hermes installation.

- Work inside this directory unless the user explicitly asks otherwise.
- Do not modify unrelated VPS services or projects without explicit instruction.
- Never print API keys, bot tokens, passwords, private keys, or .env contents.
- Ask for confirmation before destructive operations outside this workspace.

Credit: Reii
EOF
  chmod 600 "$WORKSPACE/AGENTS.md" 2>/dev/null || true
  ok "Workspace siap: $WORKSPACE"
}

test_chat() {
  [[ "$TEST_CHAT" == "1" ]] || return 0
  info "Menguji koneksi model..."
  set +e
  local output rc
  output="$("$HERMES_BIN" chat -q "Jawab tepat: HERMESLAUNCH_OK" 2>&1)"
  rc=$?
  set -e
  if [[ $rc -eq 0 ]] && grep -q "HERMESLAUNCH_OK" <<<"$output"; then
    ok "Model berhasil menjawab"
  else
    warn "Tes AI belum sukses. Gateway tetap akan dipasang."
    printf '%s\n' "$output" | tail -n 15
  fi
}

install_gateway() {
  info "Menginstall Telegram Gateway sebagai boot-time system service..."

  # Hermes builds can differ around --run-as-user. Try the stricter modern form first.
  set +e
  if [[ "$EUID" -eq 0 ]]; then
    printf 'y\ny\n' | "$HERMES_BIN" gateway install --system --run-as-user "$TARGET_USER"
    rc=$?
    if [[ $rc -ne 0 ]]; then
      warn "Mencoba fallback syntax system service..."
      printf 'y\ny\n' | "$HERMES_BIN" gateway install --system
      rc=$?
    fi
  else
    printf 'y\ny\n' | $SUDO env \
      HOME="$TARGET_HOME" HERMES_HOME="$HERMES_HOME" PATH="$PATH" \
      "$HERMES_BIN" gateway install --system --run-as-user "$TARGET_USER"
    rc=$?
    if [[ $rc -ne 0 ]]; then
      warn "Mencoba fallback syntax system service..."
      printf 'y\ny\n' | $SUDO env \
        HOME="$TARGET_HOME" HERMES_HOME="$HERMES_HOME" PATH="$PATH" \
        "$HERMES_BIN" gateway install --system
      rc=$?
    fi
  fi
  set -e

  [[ $rc -eq 0 ]] || die "Gagal memasang system service Hermes Gateway."

  sleep 3
  if [[ "$EUID" -eq 0 ]]; then
    "$HERMES_BIN" gateway status --system || true
  else
    $SUDO env HOME="$TARGET_HOME" HERMES_HOME="$HERMES_HOME" PATH="$PATH" \
      "$HERMES_BIN" gateway status --system || true
  fi

  ok "Gateway system service telah dipasang"
}

install_manager() {
  info "Memasang command 'hermeslaunch'..."
  local dst="/usr/local/bin/hermeslaunch"
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp" <<'MANAGER'
#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
export HERMES_HOME
HERMES_BIN="$(command -v hermes 2>/dev/null || true)"
[[ -n "$HERMES_BIN" ]] || { echo "Hermes tidak ditemukan di PATH."; exit 1; }

run_system() {
  if [[ "$EUID" -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

help_text() {
cat <<'EOF'
HermesLaunch — Hermes VPS Management Toolkit
Created by Reii

Usage:
  hermeslaunch status
  hermeslaunch logs
  hermeslaunch start
  hermeslaunch stop
  hermeslaunch restart
  hermeslaunch doctor
  hermeslaunch model
  hermeslaunch config
  hermeslaunch backup [output.zip]
  hermeslaunch restore <backup.zip>
  hermeslaunch update
  hermeslaunch version
EOF
}

case "${1:-status}" in
  status)
    if [[ "$EUID" -eq 0 ]]; then
      "$HERMES_BIN" gateway status --system
    else
      sudo env HOME="$HOME" HERMES_HOME="$HERMES_HOME" PATH="$PATH" "$HERMES_BIN" gateway status --system
    fi
    ;;
  logs)
    run_system journalctl -u hermes-gateway -f
    ;;
  start)
    run_system systemctl start hermes-gateway
    ;;
  stop)
    run_system systemctl stop hermes-gateway
    ;;
  restart)
    run_system systemctl restart hermes-gateway
    sleep 2
    run_system systemctl status hermes-gateway --no-pager
    ;;
  doctor) "$HERMES_BIN" doctor ;;
  model) "$HERMES_BIN" model ;;
  config) "$HERMES_BIN" config ;;
  update) "$HERMES_BIN" update --backup ;;
  version)
    echo "HermesLaunch v1.2.1"
    "$HERMES_BIN" --version
    ;;
  backup)
    out="${2:-$HOME/hermes-backup-$(date +%Y%m%d-%H%M%S).zip}"
    "$HERMES_BIN" backup -o "$out"
    chmod 600 "$out" || true
    echo "Backup: $out"
    echo "PERINGATAN: backup penuh mengandung credential. Jangan dipublish."
    ;;
  restore)
    file="${2:-}"
    [[ -n "$file" && -f "$file" ]] || { echo "Usage: hermeslaunch restore <backup.zip>"; exit 2; }
    run_system systemctl stop hermes-gateway || true
    "$HERMES_BIN" import "$file" --force
    chmod 600 "$HERMES_HOME/.env" 2>/dev/null || true
    run_system systemctl start hermes-gateway
    echo "Restore selesai."
    ;;
  help|-h|--help) help_text ;;
  *) echo "Command tidak dikenal: $1"; help_text; exit 2 ;;
esac
MANAGER
  chmod 755 "$tmp"
  $SUDO install -m 0755 "$tmp" "$dst"
  rm -f "$tmp"
  ok "Command manager tersedia: hermeslaunch"
}

final_message() {
  printf "\n${C_GREEN}${C_BOLD}HermesLaunch selesai ✅${C_RESET}\n\n"
  cat <<EOF
Provider       : custom:${PROVIDER_SLUG}
Model          : ${MODEL_ID}
Telegram User  : ${TELEGRAM_USERS}
Workspace      : ${WORKSPACE}
Hermes Home    : ${HERMES_HOME}

Command:
  hermeslaunch status
  hermeslaunch logs
  hermeslaunch restart
  hermeslaunch doctor
  hermeslaunch backup
  hermeslaunch model

Sekarang buka bot Telegram kamu lalu kirim:
  Halo Hermes, apakah kamu online?

Keamanan:
  • Bot dibatasi ke Telegram ID yang kamu masukkan.
  • Credential berada di ${HERMES_HOME}/.env (mode 600).
  • Jangan pernah publish .env atau full Hermes backup.
EOF
}

main() {
  banner
  check_platform
  setup_privileges
  need_tty
  install_prereqs
  ensure_python
  install_hermes
  backup_existing
  wizard
  configure_telegram
  configure_provider
  configure_workspace
  "$HERMES_BIN" config check || true
  test_chat
  install_gateway
  install_manager
  final_message
}

main "$@"

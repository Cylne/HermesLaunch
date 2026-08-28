#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

HL_VERSION="1.4.2"
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


get_python() {
  command -v python3 2>/dev/null || command -v python 2>/dev/null || true
}

provider_require_python() {
  PROVIDER_PY="$(get_python)"
  [[ -n "$PROVIDER_PY" ]] || {
    echo "Python dibutuhkan untuk Provider Manager."
    return 1
  }
}

provider_config_path() {
  ""$HERMES"" config path 2>/dev/null || printf '%s\n' "$HERMES_HOME/config.yaml"
}

provider_env_path() {
  ""$HERMES"" config env-path 2>/dev/null || printf '%s\n' "$HERMES_HOME/.env"
}

provider_json() {
  local raw
  raw="$(""$HERMES"" config get providers --json 2>/dev/null || true)"
  [[ -n "$raw" ]] && printf '%s\n' "$raw" || printf '{}\n'
}

provider_rows() {
  provider_require_python || return 1
  provider_json | "$PROVIDER_PY" -c '
import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
if not isinstance(data,dict):
    data={}
for slug,cfg in data.items():
    if not isinstance(cfg,dict):
        cfg={}
    name=str(cfg.get("name") or slug)
    api=str(cfg.get("api") or cfg.get("base_url") or "-")
    model=str(cfg.get("default_model") or "-")
    transport=str(cfg.get("transport") or "-")
    key_env=str(cfg.get("key_env") or "")
    print("\t".join([str(slug), name, api, model, transport, key_env]))
'
}

provider_list() {
  local rows
  rows="$(provider_rows || true)"
  echo
  echo "HermesLaunch Custom Providers"
  echo "────────────────────────────────────────────────────────────"
  if [[ -z "$rows" ]]; then
    echo "Belum ada custom provider di config Hermes."
    echo "Gunakan: hermeslaunch provider add"
    return 0
  fi

  printf '%-4s %-18s %-20s %-24s\n' "No" "Slug" "Name" "Default Model"
  printf '%-4s %-18s %-20s %-24s\n' "--" "------------------" "--------------------" "------------------------"
  local n=1 slug name api model transport key_env
  while IFS=$'\t' read -r slug name api model transport key_env; do
    printf '%-4s %-18s %-20s %-24s\n' "$n" "$slug" "${name:0:20}" "${model:0:24}"
    n=$((n+1))
  done <<< "$rows"
  echo
  echo "Catatan: Provider Manager hanya mengelola custom provider di bagian 'providers:'."
  echo "Built-in provider Hermes tidak dihapus oleh menu ini."
}

provider_choose() {
  local prompt="${1:-Pilih provider}" rows count choice
  rows="$(provider_rows || true)"
  [[ -n "$rows" ]] || {
    echo "Belum ada custom provider."
    return 1
  }

  provider_list
  count="$(printf '%s\n' "$rows" | grep -c . || true)"
  printf "%s [1-%s]: " "$prompt" "$count" > /dev/tty
  IFS= read -r choice < /dev/tty || true
  [[ "$choice" =~ ^[0-9]+$ ]] || { echo "Pilihan tidak valid."; return 1; }
  (( choice >= 1 && choice <= count )) || { echo "Pilihan di luar daftar."; return 1; }
  printf '%s\n' "$rows" | sed -n "${choice}p" | cut -f1
}

provider_env_get() {
  provider_require_python || return 1
  local key="$1" env_path
  env_path="$(provider_env_path)"
  "$PROVIDER_PY" - "$env_path" "$key" <<'PY'
from pathlib import Path
import json, sys
p=Path(sys.argv[1]); key=sys.argv[2]
if not p.exists():
    raise SystemExit
for raw in p.read_text(encoding="utf-8").splitlines():
    line=raw.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    k,v=line.split("=",1)
    if k.strip()!=key:
        continue
    v=v.strip()
    try:
        if v.startswith(("\"", "'")):
            print(json.loads(v) if v.startswith("\"") else v[1:-1])
        else:
            print(v)
    except Exception:
        print(v.strip("\"'"))
    break
PY
}

provider_env_unset() {
  provider_require_python || return 1
  local key="$1" env_path
  env_path="$(provider_env_path)"
  [[ -f "$env_path" ]] || return 0

  "$PROVIDER_PY" - "$env_path" "$key" <<'PY'
from pathlib import Path
import os,re,sys,tempfile
p=Path(sys.argv[1]); key=sys.argv[2]
lines=p.read_text(encoding="utf-8").splitlines()
pat=re.compile(r"^\s*"+re.escape(key)+r"\s*=")
out=[line for line in lines if not pat.match(line)]
tmp=p.with_suffix(p.suffix+".hermeslaunch.tmp")
tmp.write_text("\n".join(out).rstrip()+"\n" if out else "", encoding="utf-8")
os.chmod(tmp,0o600)
tmp.replace(p)
os.chmod(p,0o600)
PY
}

provider_field() {
  provider_require_python || return 1
  local slug="$1" field="$2" raw
  raw="$(""$HERMES"" config get "providers.${slug}" --json 2>/dev/null || true)"
  printf '%s\n' "$raw" | "$PROVIDER_PY" -c '
import json,sys
field=sys.argv[1]
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
if isinstance(data,dict):
    val=data.get(field,"")
    if val is None: val=""
    if isinstance(val,(dict,list)):
        print(json.dumps(val))
    else:
        print(val)
' "$field"
}

provider_current() {
  provider_require_python || return 1
  local raw
  raw="$(""$HERMES"" config get model.provider --json 2>/dev/null || true)"
  if [[ -z "$raw" ]]; then
    ""$HERMES"" config get model.provider 2>/dev/null || true
    return
  fi
  printf '%s\n' "$raw" | "$PROVIDER_PY" -c '
import json,sys
s=sys.stdin.read().strip()
try:
    v=json.loads(s)
    print(v if not isinstance(v,(dict,list)) else "")
except Exception:
    print(s.strip("\""))
'
}

provider_backup() {
  local config_path env_path ts dir
  config_path="$(provider_config_path)"
  env_path="$(provider_env_path)"
  ts="$(date +%Y%m%d-%H%M%S)"
  dir="$HERMES_HOME/backups/hermeslaunch-provider-$ts"
  mkdir -p "$dir"

  [[ -f "$config_path" ]] && cp -a "$config_path" "$dir/config.yaml"
  if [[ -f "$env_path" ]]; then
    cp -a "$env_path" "$dir/.env"
    chmod 600 "$dir/.env" 2>/dev/null || true
  fi
  chmod 700 "$dir" 2>/dev/null || true
  printf '%s\n' "$dir"
}

provider_add() {
  echo
  echo "Add Provider"
  echo "HermesLaunch membuka wizard model/provider resmi Hermes."
  echo "Pilih custom provider jika ingin menambahkan endpoint baru."
  ""$HERMES"" model
}

provider_switch() {
  echo
  echo "Switch Provider / Model"
  ""$HERMES"" model
  stop_gateway; start_gateway
}

provider_test() {
  local slug="${1:-}" api key_env key code body
  [[ -n "$slug" ]] || slug="$(provider_choose "Provider yang mau dites")" || return 1

  api="$(provider_field "$slug" api)"
  [[ -n "$api" ]] || api="$(provider_field "$slug" base_url)"
  key_env="$(provider_field "$slug" key_env)"
  key=""
  [[ -n "$key_env" ]] && key="$(provider_env_get "$key_env" || true)"

  [[ -n "$api" ]] || {
    echo "Provider '$slug' tidak memiliki API/Base URL yang bisa dites."
    return 1
  }

  echo
  echo "Testing provider: $slug"
  echo "Endpoint        : ${api%/}/models"
  echo "Authentication  : $([[ -n "$key" && "$key" != "no-key-required" ]] && echo configured || echo none/keyless)"
  echo "API key tidak akan ditampilkan."

  body="$(mktemp)"
  if [[ -n "$key" && "$key" != "no-key-required" ]]; then
    code="$(curl -sS --connect-timeout 10 --max-time 20 -o "$body" -w '%{http_code}' \
      -H "Authorization: Bearer $key" -H "Accept: application/json" \
      "${api%/}/models" || true)"
  else
    code="$(curl -sS --connect-timeout 10 --max-time 20 -o "$body" -w '%{http_code}' \
      -H "Accept: application/json" "${api%/}/models" || true)"
  fi
  rm -f "$body"

  if [[ "$code" =~ ^2 ]]; then
    echo "✓ Provider reachable (HTTP $code)"
  else
    echo "! /models returned HTTP ${code:-N/A}"
    echo "  Ini belum tentu berarti provider rusak; beberapa endpoint tidak menyediakan /models."
    return 1
  fi
}

provider_remove() {
  local slug="${1:-}" current key_env backup answer
  [[ -n "$slug" ]] || slug="$(provider_choose "Provider yang mau dihapus")" || return 1

  # Verify it exists in custom providers.
  if ! provider_rows | cut -f1 | grep -Fxq "$slug"; then
    echo "Custom provider '$slug' tidak ditemukan."
    return 1
  fi

  current="$(provider_current || true)"
  if [[ "$current" == "custom:$slug" ]]; then
    echo
    echo "Provider '$slug' sedang AKTIF."
    echo "Sebelum dihapus, pilih provider/model pengganti."
    ""$HERMES"" model
    current="$(provider_current || true)"
    if [[ "$current" == "custom:$slug" ]]; then
      echo "Provider masih aktif. Penghapusan dibatalkan untuk mencegah config rusak."
      return 1
    fi
  fi

  key_env="$(provider_field "$slug" key_env)"
  echo
  echo "Provider : $slug"
  echo "Key Env  : ${key_env:-none}"
  echo
  echo "Yang akan dilakukan:"
  echo "  • backup config.yaml + .env"
  echo "  • hapus custom provider '$slug' dari config"
  if [[ "$key_env" == HERMESLAUNCH_*_API_KEY ]]; then
    echo "  • hapus secret '$key_env' milik HermesLaunch dari .env"
  elif [[ -n "$key_env" ]]; then
    echo "  • secret '$key_env' DIPERTAHANKAN karena mungkin dipakai provider lain"
  fi
  echo "  • provider lain tidak disentuh"

  printf "Lanjut hapus provider '%s'? [y/N]: " "$slug" > /dev/tty
  IFS= read -r answer < /dev/tty || true
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "Dibatalkan."; return 0; }

  backup="$(provider_backup)"
  ""$HERMES"" config unset "providers.${slug}"

  if [[ "$key_env" == HERMESLAUNCH_*_API_KEY ]]; then
    provider_env_unset "$key_env"
  fi

  if ""$HERMES"" config check; then
    stop_gateway; start_gateway
    echo
    echo "✓ Provider '$slug' berhasil dihapus."
    echo "Backup: $backup"
  else
    echo
    echo "Config check gagal."
    echo "Backup tersedia di: $backup"
    echo "Gateway tidak direstart."
    return 1
  fi
}

provider_menu() {
  local choice slug
  while true; do
    echo
    echo "╭──────────────────────────────────────────────╮"
    echo "│      HermesLaunch Provider Manager          │"
    echo "╰──────────────────────────────────────────────╯"
    echo "1. List custom providers"
    echo "2. Add provider"
    echo "3. Switch provider / model"
    echo "4. Test provider"
    echo "5. Remove provider"
    echo "6. Back"
    printf "Pilih [1-6]: " > /dev/tty
    IFS= read -r choice < /dev/tty || true
    case "$choice" in
      1) provider_list ;;
      2) provider_add ;;
      3) provider_switch ;;
      4) slug="$(provider_choose "Provider yang mau dites")" && provider_test "$slug" || true ;;
      5) slug="$(provider_choose "Provider yang mau dihapus")" && provider_remove "$slug" || true ;;
      6|"") return 0 ;;
      *) echo "Pilihan tidak valid." ;;
    esac
  done
}

provider_command() {
  local sub="${1:-menu}" slug="${2:-}"
  case "$sub" in
    menu|"") provider_menu ;;
    list|ls) provider_list ;;
    add) provider_add ;;
    switch|use|change) provider_switch ;;
    test) provider_test "$slug" ;;
    remove|rm|delete) provider_remove "$slug" ;;
    *)
      echo "Usage:"
      echo "  hermeslaunch provider"
      echo "  hermeslaunch provider list"
      echo "  hermeslaunch provider add"
      echo "  hermeslaunch provider switch"
      echo "  hermeslaunch provider test [slug]"
      echo "  hermeslaunch provider remove [slug]"
      return 2
      ;;
  esac
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
  provider|providers)
    provider_command "${2:-menu}" "${3:-}"
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
    echo "HermesLaunch v1.4.2 — Termux Mobile Mode"
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
  hermeslaunch provider
  hermeslaunch provider list
  hermeslaunch provider remove [slug]
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

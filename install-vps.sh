#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

HL_VERSION="1.4.2"
HERMESLAUNCH_REPO="${HERMESLAUNCH_REPO:-Cylne/HermesLaunch}"
HERMESLAUNCH_REF="${HERMESLAUNCH_REF:-main}"
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
HermesLaunch v1.4.2 ditujukan untuk VPS Linux + systemd.

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
  [[ "$(uname -s)" == "Linux" ]] || die "HermesLaunch v1.4.2 hanya mendukung Linux VPS."
  command -v systemctl >/dev/null 2>&1 || die "systemd tidak ditemukan. HermesLaunch v1.4.2 membutuhkan systemd."
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
  ""$HERMES_BIN"" config path 2>/dev/null || printf '%s\n' "$HERMES_HOME/config.yaml"
}

provider_env_path() {
  ""$HERMES_BIN"" config env-path 2>/dev/null || printf '%s\n' "$HERMES_HOME/.env"
}

provider_json() {
  local raw
  raw="$(""$HERMES_BIN"" config get providers --json 2>/dev/null || true)"
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
  raw="$(""$HERMES_BIN"" config get "providers.${slug}" --json 2>/dev/null || true)"
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
  raw="$(""$HERMES_BIN"" config get model.provider --json 2>/dev/null || true)"
  if [[ -z "$raw" ]]; then
    ""$HERMES_BIN"" config get model.provider 2>/dev/null || true
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
  ""$HERMES_BIN"" model
}

provider_switch() {
  echo
  echo "Switch Provider / Model"
  ""$HERMES_BIN"" model
  run_system systemctl restart hermes-gateway || true
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
    ""$HERMES_BIN"" model
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
  ""$HERMES_BIN"" config unset "providers.${slug}"

  if [[ "$key_env" == HERMESLAUNCH_*_API_KEY ]]; then
    provider_env_unset "$key_env"
  fi

  if ""$HERMES_BIN"" config check; then
    run_system systemctl restart hermes-gateway || true
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
  hermeslaunch provider
  hermeslaunch provider list
  hermeslaunch provider remove [slug]
  hermeslaunch tools
  hermeslaunch tools status
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
  provider|providers)
    provider_command "${2:-menu}" "${3:-}"
    ;;
  tools|toolbox|stack)
    if command -v hermestools >/dev/null 2>&1; then
      shift || true
      exec hermestools "$@"
    else
      echo "HermesTools belum terinstall."
      echo "Jalankan bootstrap-tools.sh dari repository HermesLaunch v1.4.2."
      exit 1
    fi
    ;;
  config) "$HERMES_BIN" config ;;
  update) "$HERMES_BIN" update --backup ;;
  version)
    echo "HermesLaunch v1.4.2"
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


offer_allin_tools() {
  if ! confirm "Install All-In AI Stack (9Router + Genspark + Hermes Skills) sekarang?" "Y"; then
    warn "All-In Tools dilewati. Nanti jalankan bootstrap-tools.sh."
    return 0
  fi

  info "Memulai All-In AI Stack installer..."
  local tmp base
  tmp="$(mktemp)"
  base="https://raw.githubusercontent.com/${HERMESLAUNCH_REPO}/${HERMESLAUNCH_REF}"
  curl -fsSL "${base}/bootstrap-tools.sh" -o "$tmp"
  chmod 700 "$tmp"

  set +e
  HERMESLAUNCH_REPO="$HERMESLAUNCH_REPO" \
  HERMESLAUNCH_REF="$HERMESLAUNCH_REF" \
    bash "$tmp"
  local rc=$?
  set -e
  rm -f "$tmp"

  if [[ $rc -eq 0 ]]; then
    ok "All-In AI Stack setup selesai"
  else
    warn "All-In AI Stack belum selesai (exit $rc). Hermes utama tetap terinstall."
    warn "Jalankan lagi nanti: curl -fsSL ${base}/bootstrap-tools.sh | bash"
  fi
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
  hermeslaunch provider
  hermeslaunch tools        # setelah All-In Tools dipasang

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
  offer_allin_tools
  final_message
}

main "$@"

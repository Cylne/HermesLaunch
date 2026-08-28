#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${HERMESLAUNCH_REPO:-Cylne/HermesLaunch}"
REF="${HERMESLAUNCH_REF:-main}"
BASE="https://raw.githubusercontent.com/${REPO}/${REF}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

run_root() {
  if [[ "$EUID" -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

local_mode=0
if [[ -f "$ROOT/hermestools" && -d "$ROOT/skills" ]]; then
  local_mode=1
fi

if [[ "$local_mode" == "1" ]]; then
  MANAGER="$ROOT/hermestools"
  SKILLS="$ROOT/skills"
else
  mkdir -p "$TMP/skills/research/genspark" \
           "$TMP/skills/infrastructure/router9" \
           "$TMP/skills/infrastructure/ai-stack"

  curl -fsSL "$BASE/toolbox/hermestools" -o "$TMP/hermestools"
  curl -fsSL "$BASE/toolbox/skills/research/genspark/SKILL.md" \
    -o "$TMP/skills/research/genspark/SKILL.md"
  curl -fsSL "$BASE/toolbox/skills/infrastructure/router9/SKILL.md" \
    -o "$TMP/skills/infrastructure/router9/SKILL.md"
  curl -fsSL "$BASE/toolbox/skills/infrastructure/ai-stack/SKILL.md" \
    -o "$TMP/skills/infrastructure/ai-stack/SKILL.md"

  MANAGER="$TMP/hermestools"
  SKILLS="$TMP/skills"
fi

bash -n "$MANAGER"
chmod 755 "$MANAGER"

run_root install -d -m 0755 /usr/local/share/hermestools
run_root rm -rf /usr/local/share/hermestools/skills
run_root cp -a "$SKILLS" /usr/local/share/hermestools/skills
run_root install -m 0755 "$MANAGER" /usr/local/bin/hermestools

echo "✓ HermesTools installed: /usr/local/bin/hermestools"
echo "✓ Shared skills installed: /usr/local/share/hermestools/skills"
echo

exec /usr/local/bin/hermestools setup

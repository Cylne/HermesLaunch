#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_root() {
  if [[ "$EUID" -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

[[ -f "$ROOT/agentstack" ]] || {
  echo "agentstack manager tidak ditemukan." >&2
  exit 1
}

bash -n "$ROOT/agentstack"

run_root install -d -m 0755 /usr/local/share/hermeslaunch-agentstack
run_root rm -rf /usr/local/share/hermeslaunch-agentstack/skills
run_root cp -a "$ROOT/skills" /usr/local/share/hermeslaunch-agentstack/skills
run_root install -m 0755 "$ROOT/agentstack" /usr/local/bin/agentstack

echo "✓ agentstack installed: /usr/local/bin/agentstack"
echo "✓ skills installed: /usr/local/share/hermeslaunch-agentstack/skills"
echo

exec /usr/local/bin/agentstack setup

#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/bootstrap.sh"
bash -n "$ROOT/bootstrap-agents.sh"
bash -n "$ROOT/install.sh"
bash -n "$ROOT/install-vps.sh"
bash -n "$ROOT/install-termux.sh"
bash -n "$ROOT/agentstack/install-agentstack.sh"
bash -n "$ROOT/agentstack/agentstack"
bash -n "$ROOT/scripts/set-repo.sh"
bash -n "$ROOT/scripts/release.sh"

grep -q '^name: opencode$' "$ROOT/agentstack/skills/coding/opencode/SKILL.md"
grep -q '^name: openclaw$' "$ROOT/agentstack/skills/infrastructure/openclaw/SKILL.md"
grep -q '^name: multi-agent$' "$ROOT/agentstack/skills/infrastructure/multi-agent/SKILL.md"

bash "$ROOT/agentstack/agentstack" version
bash "$ROOT/agentstack/agentstack" help >/dev/null

scan_out="$(
  grep -RInE \
    --exclude='*.md' \
    --exclude-dir='.git' \
    '(sk-[A-Za-z0-9_-]{20,}|[0-9]{7,12}:[A-Za-z0-9_-]{30,}|-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----)' \
    "$ROOT" || true
)"
scan_out="$(printf '%s\n' "$scan_out" | grep -v 'AAxxxxxxxx' || true)"
if [[ -n "$scan_out" ]]; then
  printf '%s\n' "$scan_out"
  echo "Potential embedded secret found."
  exit 1
fi

echo "HermesLaunch v1.5.0 self-test: PASS"

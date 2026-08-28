#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/bootstrap.sh"
bash -n "$ROOT/bootstrap-tools.sh"
bash -n "$ROOT/install.sh"
bash -n "$ROOT/install-vps.sh"
bash -n "$ROOT/install-termux.sh"
bash -n "$ROOT/toolbox/install-ai-stack.sh"
bash -n "$ROOT/toolbox/hermestools"

grep -q '^name: genspark$' "$ROOT/toolbox/skills/research/genspark/SKILL.md"
grep -q '^name: router9$' "$ROOT/toolbox/skills/infrastructure/router9/SKILL.md"
grep -q '^name: ai-stack$' "$ROOT/toolbox/skills/infrastructure/ai-stack/SKILL.md"

scan_out="$(
  grep -RInE \
    --exclude='*.md' \
    --exclude-dir='.git' \
    '(gsk_[A-Za-z0-9_-]{12,}|[0-9]{7,12}:[A-Za-z0-9_-]{30,}|-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----)' \
    "$ROOT" || true
)"
scan_out="$(printf '%s\n' "$scan_out" | grep -v 'AAxxxxxxxx' || true)"
if [[ -n "$scan_out" ]]; then
  printf '%s\n' "$scan_out"
  echo "Potential embedded secret found."
  exit 1
fi

bash "$ROOT/toolbox/hermestools" version
bash "$ROOT/toolbox/hermestools" help >/dev/null

echo "HermesLaunch v1.4.1 self-test: PASS"

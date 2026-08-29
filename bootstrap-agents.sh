#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${HERMESLAUNCH_REPO:-Cylne/HermesLaunch}"
REF="${HERMESLAUNCH_REF:-main}"
BASE="https://raw.githubusercontent.com/${REPO}/${REF}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p \
  "$TMP/skills/coding/opencode" \
  "$TMP/skills/infrastructure/openclaw" \
  "$TMP/skills/infrastructure/multi-agent"

curl -fsSL "$BASE/agentstack/agentstack" -o "$TMP/agentstack"
curl -fsSL "$BASE/agentstack/install-agentstack.sh" -o "$TMP/install-agentstack.sh"
curl -fsSL "$BASE/agentstack/skills/coding/opencode/SKILL.md" -o "$TMP/skills/coding/opencode/SKILL.md"
curl -fsSL "$BASE/agentstack/skills/infrastructure/openclaw/SKILL.md" -o "$TMP/skills/infrastructure/openclaw/SKILL.md"
curl -fsSL "$BASE/agentstack/skills/infrastructure/multi-agent/SKILL.md" -o "$TMP/skills/infrastructure/multi-agent/SKILL.md"

chmod 700 "$TMP/agentstack" "$TMP/install-agentstack.sh"
bash "$TMP/install-agentstack.sh"

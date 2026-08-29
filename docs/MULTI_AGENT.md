# HermesLaunch Multi-Agent Stack

## Architecture

```text
Hermes
  ├─ normal Hermes provider/model system
  └─ OpenCode for optional coding delegation

OpenClaw
  └─ optional separate Gateway/runtime
```

## OpenCode

Installer official:

```bash
curl -fsSL https://opencode.ai/install | bash
```

Usage:

```bash
opencode
opencode run "Explain this repository"
```

Configure provider from the OpenCode TUI using `/connect`.

## OpenClaw

Installer official:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

Onboarding:

```bash
openclaw onboard --install-daemon
```

Status:

```bash
openclaw gateway status
```

If Hermes already uses Telegram, use a different bot token for OpenClaw.

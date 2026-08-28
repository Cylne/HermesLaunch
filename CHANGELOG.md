# Changelog

## [1.3.0] - 2026-08-28

### Added
- HermesLaunch Provider Manager for VPS and Termux.
- Interactive `hermeslaunch provider` menu.
- `provider list`, `add`, `switch`, `test`, and `remove` commands.
- Safe provider removal with config/.env backup.
- Active-provider protection before removal.
- Shared API-key protection.
- Connectivity test through provider `/models`.
- Dedicated Provider Manager documentation.
- Professional Telegram Bot Features section in README.
- Telegram slash-command feature list including sessions, model switch, usage, approvals, home channel, and topic mode.

### Safety
- Provider removal is confirmation-gated.
- Built-in Hermes providers are not removed.
- Generic/shared API keys are preserved.
- Gateway restarts only after `hermes config check` succeeds.

### Runtime
- VPS Mode remains systemd-based.
- Termux Mode remains native Termux + tmux.

### Repository
- https://github.com/Cylne/HermesLaunch.git

### Credits
Created by **Reii**.

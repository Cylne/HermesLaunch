# Changelog

## v1.4.1 — GitHub CI Permission Fix

### Fixed
- Repository self-test no longer executes `toolbox/hermestools` directly.
- `hermestools` is invoked through `bash`, so CI works even when executable bits are lost during ZIP/browser/bot uploads.
- GitHub Actions now syntax-checks all All-In stack scripts before running the repository self-test.
- Runtime installers still apply executable mode when installing `hermestools` to `/usr/local/bin`.

### Compatibility
- No provider configuration changes.
- No 9Router data changes.
- No Genspark authentication changes.
- Existing Hermes providers remain preserved.

## v1.4.1 — All-In AI Stack

### Added
- `bootstrap-tools.sh` for existing Hermes VPS installations.
- `toolbox/install-ai-stack.sh`.
- `hermestools` interactive manager.
- 9Router Docker install/repair, localhost-only binding, status/log/update/model management.
- Safe Hermes named custom provider registration as `custom:9router`.
- Existing Hermes provider remains active unless user explicitly switches.
- Genspark CLI install/update and authentication wizard.
- `gskh` credential-safe wrapper.
- Genspark generated skill reference sync with `gsk init-skills`.
- Hermes skills: `genspark`, `router9`, `ai-stack`.
- Hermes config/.env backup and rollback on failed provider configuration.
- `hermeslaunch tools` shortcut on new v1.4.1 VPS installs.

### Security
- 9Router defaults to `127.0.0.1:20128`.
- External login/OAuth is never bypassed.
- Genspark API key is stored locally with mode 600 and never echoed.
- Unrelated VPS services/projects are not touched.

## [1.4.1] - 2026-08-28

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

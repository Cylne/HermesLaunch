# Changelog

## [1.1.0] - 2026-08-28

### Added
- Branding **HermesLaunch**.
- One-command `bootstrap.sh`.
- Single interactive wizard for Telegram + custom AI provider.
- Automatic `/models` discovery.
- Mandatory Telegram numeric-ID allowlist.
- VPS systemd gateway installation.
- `hermeslaunch` management command.
- Full Hermes backup/restore wrapper.
- Android Termux remote-VPS tutorial.
- Provider, migration, command, and publishing guides.
- GitHub Actions shell validation.
- Release builder with SHA-256 checksums.

### Security
- Secrets stored in `~/.hermes/.env` with mode `0600`.
- Remote plain-HTTP provider endpoints rejected.
- Open Telegram access intentionally unsupported.

### Credits
Created by **Reii**.

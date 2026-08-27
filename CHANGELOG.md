# Changelog

## [1.2.0] - 2026-08-28

### Added
- Separate VPS Mode and native Android/Termux Mobile Mode.
- `install-vps.sh` for systemd deployments.
- `install-termux.sh` for no-VPS Android deployments.
- Auto-dispatching `install.sh` and `bootstrap.sh`.
- Termux tmux gateway manager using `hermes gateway run`.
- Optional wake-lock integration and Termux:Boot helper.
- Dedicated Termux documentation.

### Changed
- Canonical repository: `https://github.com/Cylne/HermesLaunch.git`.
- README now explicitly treats VPS and Termux as different environments.
- Termux is documented as best-effort, while VPS is the stable 24/7 path.

### Credits
Created by **Reii**.

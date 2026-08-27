# 📱 HermesLaunch — Termux Mobile Mode

This guide is specifically for **running Hermes directly on Android via Termux without a VPS**.

Hermes' official Android path supports a native Termux install. HermesLaunch therefore does **not** require Ubuntu/proot.

## Architecture

```text
Android
  ↓
Termux
  ↓
Hermes Agent
  ↓
tmux background session
  ↓
hermes gateway run
  ↓
Telegram
```

## 1. Prepare Termux

```bash
pkg update -y
pkg upgrade -y
pkg install -y git curl
```

## 2. Install

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

HermesLaunch automatically selects `install-termux.sh`.


### Apa yang perlu disiapkan?

```text
Bot Token                 → dari @BotFather
Telegram numeric User ID  → dari @userinfobot / @get_id_bot
Home Channel              → User ID sendiri untuk DM pribadi
API Base URL              → endpoint provider
API Key                   → key provider
Model ID                  → ID model persis
```

Kalau muncul:

```text
Home Channel [1447854280]:
```

dan kamu ingin cron/notifikasi masuk ke DM sendiri, **tekan Enter saja**.

Untuk grup/forum, gunakan Chat ID seperti `-1001234567890`.

## 3. Provider setup

The Termux installer launches:

```bash
hermes model
```

Use the Hermes provider wizard normally.

## 4. Telegram setup

Then HermesLaunch launches:

```bash
hermes gateway setup
```

Choose Telegram and enter:

- Bot Token from `@BotFather`
- numeric Telegram User ID

Do not leave access open to everyone.

## 5. Gateway runtime

Hermes recommends the foreground gateway command for Termux:

```bash
hermes gateway run
```

HermesLaunch keeps that command in a `tmux` session named:

```text
hermeslaunch-gateway
```

Manage it with:

```bash
hermeslaunch status
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch logs
```

## 6. Android background limitation

Android can suspend Termux background jobs.

Recommended Android-side settings:

- Battery → Termux → Unrestricted / Don't optimize
- allow background/autostart if your ROM exposes it
- don't force-stop Termux

HermesLaunch attempts `termux-wake-lock` when that command is available.

This remains **best-effort** and is not equivalent to a VPS systemd service.

## 7. Termux:Boot

The installer can create:

```text
~/.termux/boot/hermeslaunch-gateway.sh
```

You still need the separate Termux:Boot application.

It attempts to start HermesLaunch after Android reboot, but Android can still kill background processes later.

## 8. Workspace

Recommended local workspace:

```text
~/Reii
```

For Android Download access:

```bash
termux-setup-storage
```

Copy a project:

```bash
cp -r ~/Reii/NamaProject ~/storage/downloads/
```

## 9. Backup

```bash
hermeslaunch backup ~/hermes-backup.zip
```

Copy it to Android Download:

```bash
cp ~/hermes-backup.zip ~/storage/downloads/
```

⚠️ The backup contains sensitive Hermes data and credentials.

## 10. Termux vs VPS

| | Termux | VPS |
|---|---|---|
| VPS needed | No | Yes |
| Ubuntu/proot | No | N/A |
| Supervisor | tmux | systemd |
| Gateway command | `hermes gateway run` | system service |
| Reboot persistence | optional Termux:Boot | native systemd |
| 24/7 reliability | best-effort | recommended |
| Android can terminate runtime | yes | no |

Repository: https://github.com/Cylne/HermesLaunch.git

Credits: Reii

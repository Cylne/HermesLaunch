<div align="center">

# 🚀 HermesLaunch

### Hermes VPS Deployment & Management Toolkit

**Install Hermes Agent, connect Telegram, configure an AI provider, and run the gateway 24/7 — from one guided installer.**

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](#)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](#)
[![Platform](https://img.shields.io/badge/platform-Linux%20VPS-FCC624?logo=linux&logoColor=black)](#)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Created by Reii**

</div>

---

## ✨ What is HermesLaunch?

HermesLaunch adalah deployment wrapper independen untuk membantu user memasang **Hermes Agent** di VPS tanpa mengulang setup manual satu per satu.

```text
Android / PC
     │
     │ SSH / Telegram
     ▼
┌───────────────────────┐
│      Linux VPS        │
│                       │
│  HermesLaunch         │
│       ↓               │
│  Hermes Agent         │
│       ↓               │
│  Telegram Gateway     │
│       ↓               │
│  AI Provider          │
└───────────────────────┘
```

HermesLaunch tidak mengganti atau memodifikasi source Hermes Agent. Hermes tetap diinstall menggunakan installer resmi Hermes.

> **Independent project:** HermesLaunch bukan software resmi Nous Research dan tidak berafiliasi dengan Nous Research.

---

## ⚡ One-Command Install

Setelah repo ini dipublish dan placeholder repo sudah dikonfigurasi:

```bash
curl -fsSL https://raw.githubusercontent.com/__GITHUB_REPO__/main/bootstrap.sh | bash
```

Atau metode yang lebih transparan:

```bash
git clone https://github.com/__GITHUB_REPO__.git
cd HermesLaunch
bash install.sh
```

> Untuk production/security-sensitive server, inspect script sebelum menjalankan `curl | bash`.

---

## 🧙 Setup Wizard

HermesLaunch meminta data hanya dalam satu flow:

```text
╭──────────────────────────────────────────────╮
│               HermesLaunch                   │
│     VPS Deployment & Management Toolkit      │
│                                              │
│               Created by Reii                │
╰──────────────────────────────────────────────╯

1/3 — Telegram
Bot Token:
Telegram numeric User ID:
Home Channel:

2/3 — AI Provider
Provider name:
API Base URL:
API Key:
API Compatibility:
Detected models:
Default Model:
Context Length:

3/3 — Workspace
Project folder:
```

Setelah selesai:

```text
✓ Hermes installed
✓ Telegram configured
✓ User allowlist configured
✓ AI provider configured
✓ Workspace created
✓ Gateway installed as system service
✓ Auto-start on boot
✓ Management command installed
```

---

## 🔥 Features

| Feature | Status |
|---|:---:|
| Official Hermes installer | ✅ |
| Telegram Bot setup | ✅ |
| Mandatory user allowlist | ✅ |
| Custom AI provider | ✅ |
| OpenAI Chat Completions | ✅ |
| Responses / Codex mode | ✅ |
| Anthropic Messages proxy | ✅ |
| `/models` discovery | ✅ |
| 9Router/local gateway friendly | ✅ |
| Workspace isolation guidance | ✅ |
| systemd 24/7 gateway | ✅ |
| Auto-start after reboot | ✅ |
| Backup / Restore | ✅ |
| VPS migration workflow | ✅ |
| Termux Android guide | ✅ |
| Secret file mode `0600` | ✅ |

---

## 📋 Requirements

Recommended:

- Ubuntu / Debian VPS
- systemd
- root or sudo access
- Internet connection
- Telegram account
- Bot created via `@BotFather`
- Numeric Telegram User ID
- AI provider endpoint + API key + model

Hermes itself supports more Linux distributions; HermesLaunch uses the tools available on common VPS distributions and checks for systemd.

---

## 📱 Android / Termux

HermesLaunch is designed so kamu bisa mengelola VPS sepenuhnya dari Android.

Quick start:

```bash
pkg update -y
pkg install -y openssh curl git
ssh root@IP_VPS
```

Kemudian jalankan HermesLaunch **di VPS**, bukan di shell Termux lokal.

📖 Full tutorial: **[docs/TERMUX.md](docs/TERMUX.md)**

---

## 🔌 AI Providers

HermesLaunch dapat mengkonfigurasi named custom provider Hermes.

Contoh OpenAI-compatible:

```text
Provider : MyAPI
Base URL : https://api.example.com/v1
Mode     : Chat Completions
Model    : my-coding-model
```

Contoh 9Router lokal:

```text
Provider : 9Router
Base URL : http://127.0.0.1:20128/v1
Mode     : Chat Completions
```

Remote plain HTTP sengaja ditolak. HTTP hanya diperbolehkan untuk loopback.

📖 Provider guide: **[docs/PROVIDERS.md](docs/PROVIDERS.md)**

---

## 🛠 Management Commands

```bash
hermeslaunch status
hermeslaunch logs
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch doctor
hermeslaunch model
hermeslaunch config
hermeslaunch backup
hermeslaunch restore backup.zip
hermeslaunch update
hermeslaunch version
```

📖 Full command reference: **[docs/COMMANDS.md](docs/COMMANDS.md)**

---

## 💾 Backup & VPS Migration

VPS lama:

```bash
hermeslaunch backup ~/hermes-migration.zip
```

Copy ke VPS baru:

```bash
scp ~/hermes-migration.zip root@IP_VPS_BARU:~/
```

Setelah HermesLaunch terinstall di VPS baru:

```bash
hermeslaunch restore ~/hermes-migration.zip
```

📖 Migration guide: **[docs/MIGRATION.md](docs/MIGRATION.md)**

> ⚠️ Full Hermes backup berisi credential. Jangan dipublish atau dibagikan.

---

## 🔐 Security

HermesLaunch mengambil beberapa keputusan keamanan secara default:

- Telegram allowlist wajib.
- Bot open-access tidak ditawarkan.
- Bot Token dan API key disimpan di `~/.hermes/.env`.
- `.env` menggunakan permission `0600`.
- Remote provider harus HTTPS.
- Config lama dibackup sebelum diubah.
- API key tidak ditampilkan ulang setelah setup.
- Workspace mendapatkan `AGENTS.md` berisi guardrail dasar.

### Root warning

Hermes memiliki terminal tools. Jika dijalankan sebagai root, agent dapat memiliki akses root ke VPS.

Untuk VPS pribadi ini sering praktis. Untuk lingkungan shared atau high-security, gunakan account Linux khusus dengan prinsip least privilege.

---

## 🧪 Development

Validate scripts:

```bash
bash -n install.sh
bash -n bootstrap.sh
bash -n scripts/*.sh
```

Build release:

```bash
./scripts/release.sh
```

GitHub Actions juga menjalankan Bash syntax check dan ShellCheck.

---

## 🚀 Publishing Your Fork

Sebelum publish:

```bash
./scripts/set-repo.sh USERNAME/HermesLaunch
```

Lalu ikuti:

**[docs/PUBLISHING.md](docs/PUBLISHING.md)**

---

## 🗂 Project Structure

```text
HermesLaunch/
├── install.sh
├── bootstrap.sh
├── VERSION
├── README.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
├── bin/
│   └── hermeslaunch
├── docs/
│   ├── TERMUX.md
│   ├── PROVIDERS.md
│   ├── COMMANDS.md
│   ├── MIGRATION.md
│   └── PUBLISHING.md
├── scripts/
│   ├── set-repo.sh
│   └── release.sh
└── .github/
    ├── workflows/
    │   └── shellcheck.yml
    └── ISSUE_TEMPLATE/
        └── bug_report.md
```

---

## 🤝 Credits

**HermesLaunch** — Created by **Reii**

Hermes Agent is a separate open-source project by **Nous Research**.

HermesLaunch is an independent installer/management wrapper and is **not affiliated with or endorsed by Nous Research**.

---

<div align="center">

### HermesLaunch

**Deploy once. Control from anywhere.**

Created by **Reii**

</div>

<div align="center">

# 🚀 HermesLaunch

### Hermes Agent Deployment Toolkit for Linux VPS & Android Termux

**One repository — two intentionally different runtime modes.**

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com/Cylne/HermesLaunch/releases)
[![VPS](https://img.shields.io/badge/VPS-systemd-success.svg)](https://github.com/Cylne/HermesLaunch)
[![Termux](https://img.shields.io/badge/Android-Termux-black.svg)](docs/TERMUX.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Created by Reii**

[Repository](https://github.com/Cylne/HermesLaunch) · [Termux Guide](docs/TERMUX.md) · [Commands](docs/COMMANDS.md) · [Security](SECURITY.md)

</div>

---

## ✨ About

HermesLaunch adalah deployment/management wrapper independen untuk **Hermes Agent**.

Tujuannya sederhana: satu repository yang membuat pemasangan Hermes + Telegram lebih praktis, tetapi **tidak menyamakan VPS dan Android Termux**.

```text
                        HermesLaunch
                             │
               ┌─────────────┴─────────────┐
               │                           │
        🖥 Linux VPS                📱 Android Termux
        VPS Mode                    Mobile Mode
               │                           │
        systemd service              native Termux
        boot-time service            tmux background
        target 24/7                  best-effort
               │                           │
               └──────────┬────────────────┘
                          ▼
                    Hermes Agent
                          │
                    Telegram Bot
                          │
                    AI Provider
```

> HermesLaunch is independent and is not affiliated with or endorsed by Nous Research.

---

# ⚡ One-Line Install

Repository:

```text
https://github.com/Cylne/HermesLaunch.git
```

Command yang sama bisa dijalankan dari VPS atau Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

`bootstrap.sh` mendeteksi environment dan mengambil installer yang sesuai:

```text
Linux VPS       → install-vps.sh
Android Termux  → install-termux.sh
```

Atau clone manual:

```bash
git clone https://github.com/Cylne/HermesLaunch.git
cd HermesLaunch
bash install.sh
```

---

# 🖥 VPS Mode

**Untuk deployment always-on / production-style.**

```text
Linux VPS
   ↓
HermesLaunch
   ↓
Hermes Agent
   ↓
systemd
   ↓
Telegram Gateway
```

### Characteristics

- Linux VPS + `systemd`
- root/sudo
- Hermes Gateway sebagai system service
- auto-start setelah reboot
- cocok untuk bot Telegram 24/7
- HP/Termux boleh ditutup

### Install

```bash
ssh root@IP_VPS
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

Setelah selesai:

```bash
hermeslaunch status
hermeslaunch logs
```

---

# 📱 Termux Mobile Mode — No VPS

**Hermes berjalan langsung di Android.**

Termux Mode bukan VPS Mode yang dibungkus Ubuntu/proot.

```text
Android
   ↓
Termux native
   ↓
Hermes Agent
   ↓
tmux
   ↓
hermes gateway run
   ↓
Telegram
```

### Tidak butuh

```text
❌ VPS
❌ Ubuntu proot
❌ systemd
```

### Menggunakan

```text
✅ Termux native
✅ installer Hermes Termux-aware
✅ tmux
✅ hermes gateway run
✅ optional wake-lock
✅ optional Termux:Boot helper
```

### Install

```bash
pkg update -y
pkg install -y git curl

curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

Termux installer kemudian menjalankan wizard resmi Hermes untuk:

1. provider/model;
2. Telegram Gateway;
3. Bot Token;
4. Telegram numeric User ID.

Setelah setup:

```bash
hermeslaunch status
hermeslaunch logs
```

### ⚠️ Termux is best-effort

Android bisa suspend/kill background process. Karena itu Termux tidak boleh didokumentasikan sebagai setara dengan systemd VPS.

Untuk membantu:

- nonaktifkan battery optimization Termux;
- izinkan background/autostart bila ROM mendukung;
- jangan force-stop Termux;
- wake-lock dipakai bila tersedia;
- Termux:Boot helper bersifat opsional.

Jika target utama adalah uptime stabil 24/7, gunakan **VPS Mode**.

📖 [Tutorial Termux lengkap](docs/TERMUX.md)

---

# 🔥 VPS vs Termux

| Capability | 🖥 VPS Mode | 📱 Termux Mode |
|---|:---:|:---:|
| Hermes CLI | ✅ | ✅ |
| Telegram Gateway | ✅ | ✅ |
| AI Provider | ✅ | ✅ |
| Project workspace | ✅ | ✅ |
| VPS required | ✅ | ❌ |
| Ubuntu/proot on Android | — | ❌ |
| Supervisor | systemd | tmux |
| Boot persistence | ✅ native | ⚠️ Termux:Boot helper |
| Android can kill process | ❌ | ✅ |
| Docker isolation | possible | ❌ |
| 24/7 reliability target | ✅ | best-effort |

---

# 🛠 HermesLaunch Commands

### VPS

```bash
hermeslaunch status
hermeslaunch logs
hermeslaunch restart
hermeslaunch doctor
hermeslaunch model
hermeslaunch backup
hermeslaunch restore
```

### Termux

```bash
hermeslaunch status
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch logs
hermeslaunch doctor
hermeslaunch model
hermeslaunch gateway-setup
hermeslaunch backup
hermeslaunch restore
```

Underlying runtime intentionally berbeda:

```text
VPS    → systemd
Termux → tmux + hermes gateway run
```

---

# 💾 Backup / Migration

```bash
hermeslaunch backup ~/hermes-backup.zip
```

Restore:

```bash
hermeslaunch restore ~/hermes-backup.zip
```

> Full Hermes backup dapat berisi API keys/Bot Token dan harus dianggap sebagai secret.

---

# 🔐 Security

- Telegram user allowlist tetap direkomendasikan/wajib saat setup.
- Jangan publish `.env`.
- Jangan publish Hermes backup.
- Gunakan HTTPS untuk remote provider endpoints.
- Hermes dengan terminal tools memiliki akses sesuai privilege OS tempat ia berjalan.
- Root VPS berarti agent bisa memiliki privilege root.

---

# 📂 Structure

```text
HermesLaunch/
├── install.sh
├── install-vps.sh
├── install-termux.sh
├── bootstrap.sh
├── README.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
├── docs/
│   ├── TERMUX.md
│   ├── PROVIDERS.md
│   ├── COMMANDS.md
│   ├── MIGRATION.md
│   └── PUBLISHING.md
└── scripts/
    ├── release.sh
    └── set-repo.sh
```

---

# 🤝 Credits

**HermesLaunch — Created by Reii**

Hermes Agent is a separate project by Nous Research.

<div align="center">

### HermesLaunch

**VPS when you need uptime. Termux when you want it directly on Android.**

Created by **Reii**

</div>

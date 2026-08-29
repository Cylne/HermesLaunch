<div align="center">

# 🚀 HermesLaunch

### Hermes Agent Deployment Toolkit for Linux VPS & Android Termux

**One repository — two intentionally different runtime modes.**

[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](https://github.com/Cylne/HermesLaunch/releases)
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

## 📸 Installation Preview

<div align="center">

<img src="assets/installation-complete.png" alt="HermesLaunch installation complete preview" width="900">

**Hermes successfully installed and ready to use.**

</div>

> Screenshot di atas menunjukkan contoh hasil instalasi Hermes pada Linux VPS. Tampilan dapat sedikit berbeda tergantung versi Hermes dan environment yang digunakan.

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

# 🧭 Apa yang Harus Diisi Saat Setup?

| Field | Isi apa? | Contoh |
|---|---|---|
| **Bot Token** | Token bot dari `@BotFather` | `123456789:AA...` |
| **Telegram numeric User ID** | ID angka akun yang boleh menggunakan bot. Ambil dari `@userinfobot` / `@get_id_bot` | `1447854280` |
| **Home Channel Chat ID** | Tujuan default cron/notifikasi. Untuk DM pribadi **cukup tekan Enter** agar sama dengan User ID utama | `1447854280` |
| **Home Channel grup** | Jika notifikasi mau ke grup/forum, gunakan Chat ID grup | `-1001234567890` |
| **Provider Name** | Label provider agar gampang dikenali | `GodenAPI`, `OpenRouter`, `9Router` |
| **API Base URL** | Base endpoint provider, biasanya `/v1` | `https://api.example.com/v1` |
| **API Key** | Secret API key provider | input disembunyikan |
| **Compatibility** | Untuk mayoritas OpenAI-compatible pilih `1` | `1` |
| **Model ID** | ID model persis dari provider | `kimi-k2.5` |
| **Context Length** | Opsional. Kalau tidak tahu tekan Enter | Enter |
| **Workspace** | Folder default project Hermes | `/root/Reii` |

### Contoh Telegram pribadi

```text
Telegram numeric User ID: 1447854280

Home Channel = tujuan default cron/notifikasi.
Kalau ingin masuk ke DM akun utama (1447854280), cukup tekan Enter.
Home Channel Chat ID [1447854280]:
```

Pada baris terakhir **cukup tekan Enter**.

`Home Channel` harus berupa **Chat ID angka** — bukan tulisan `ID`, bukan `@username`, dan bukan nama channel.

Home channel dapat diganti kemudian dari Telegram menggunakan `/sethome`.

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


# 🤖 Telegram Bot Features

HermesLaunch menghubungkan Hermes Agent ke Telegram Gateway. Setelah gateway aktif, fitur Telegram berasal dari Hermes dan dapat mencakup:

| Feature / Command | Fungsi |
|---|---|
| **Private DM & Group Chat** | Gunakan Hermes dari chat pribadi maupun grup yang dikonfigurasi |
| **Allowlist** | Batasi akun Telegram yang boleh memakai bot |
| `/new` / `/reset` | Mulai percakapan/session baru |
| `/model` | Lihat atau ganti provider + model dari Telegram |
| `/status` | Lihat informasi session aktif |
| `/sessions` | Lihat dan cari session sebelumnya |
| `/resume` | Lanjutkan session lama |
| `/title` | Beri nama session |
| `/retry` | Ulangi respons terakhir |
| `/undo` | Hapus exchange terakhir |
| `/compress` | Kompres context conversation |
| `/usage` | Lihat penggunaan token session |
| `/insights` | Lihat usage analytics |
| `/stop` | Hentikan agent yang sedang berjalan |
| `/approve` | Izinkan command berisiko yang menunggu approval |
| `/deny` | Tolak command berisiko |
| `/sethome` | Jadikan DM/grup saat ini sebagai tujuan cron/notifikasi |
| `/topic` | Multi-session topic mode pada Telegram DM bila didukung/configured |
| `/commands` | Lihat command yang tersedia |
| **Dynamic skill commands** | Skill Hermes yang terpasang dapat muncul sebagai slash command |

### Home Channel

Untuk bot pribadi:

```text
Telegram User ID : 1447854280
Home Channel     : 1447854280
```

Untuk grup/forum, Home Channel menggunakan Chat ID grup seperti:

```text
-1001234567890
```

Cron, reminder, dan proactive delivery Hermes dapat diarahkan ke Home Channel.

> Ketersediaan command tertentu mengikuti versi/configuration Hermes Agent yang terinstall.

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
hermeslaunch provider
hermeslaunch provider list
hermeslaunch provider test
hermeslaunch provider remove
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


# 🔌 Provider Manager

HermesLaunch punya menu untuk mengelola **custom AI providers** tanpa edit YAML manual:

```bash
hermeslaunch provider
```

```text
╭──────────────────────────────────────────────╮
│      HermesLaunch Provider Manager          │
╰──────────────────────────────────────────────╯
1. List custom providers
2. Add provider
3. Switch provider / model
4. Test provider
5. Remove provider
6. Back
```

Direct command juga tersedia:

```bash
hermeslaunch provider list
hermeslaunch provider test [slug]
hermeslaunch provider remove [slug]
```

### Safe Remove

Saat provider dihapus, HermesLaunch:

- membuat backup config + `.env`;
- tidak menghapus provider lain;
- mencegah provider aktif langsung dihapus;
- meminta switch model/provider terlebih dahulu jika masih aktif;
- mempertahankan shared API key;
- hanya membersihkan key khusus yang dibuat HermesLaunch;
- menjalankan `hermes config check`;
- restart gateway setelah konfigurasi valid.

> Built-in provider Hermes tidak dihapus oleh Provider Manager. Fitur ini ditujukan untuk named/custom providers.

📖 [Provider Manager guide](docs/PROVIDERS.md)

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


---

# 🤖 Multi-Agent Stack — Hermes + OpenCode + OpenClaw

HermesLaunch v1.5.0 menyederhanakan stack menjadi tiga tool yang jelas:

```text
Telegram
   ↓
Hermes Agent
   └── optional coding delegation → OpenCode

OpenClaw
   └── optional separate Gateway / agent runtime
```

## Fresh VPS

```bash
bash install.sh
```

Setelah Hermes selesai, wizard menawarkan:

```text
Install OpenCode + OpenClaw manager juga? [Y/n]
```

## Hermes sudah terinstall

Setelah v1.5.0 dipublish:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap-agents.sh | bash
```

Atau dari clone/ZIP:

```bash
bash agentstack/install-agentstack.sh
```

## Manager

```bash
agentstack
```

Menu:

```text
1. Setup / repair ALL
2. Status ALL
3. OpenCode Manager
4. OpenClaw Manager
5. Refresh Hermes skills
6. Doctor
7. Exit
```

Direct commands:

```bash
agentstack status
agentstack doctor

agentstack opencode install
agentstack opencode update
agentstack opencode status
agentstack opencode run "Explain this repository"

agentstack openclaw install
agentstack openclaw onboard
agentstack openclaw status
agentstack openclaw doctor
agentstack openclaw start
agentstack openclaw restart
agentstack openclaw stop
agentstack openclaw update
```

Shortcut dari HermesLaunch:

```bash
hermeslaunch agents
```

## Pembagian fungsi

- **Hermes**: agent utama + Telegram + provider manager lama.
- **OpenCode**: coding agent CLI. Buka `opencode`, lalu gunakan `/connect` untuk provider.
- **OpenClaw**: runtime/Gateway agent terpisah. Onboarding hanya dijalankan saat diperlukan.

Jangan menggunakan token Telegram bot yang sama untuk Hermes dan OpenClaw secara bersamaan.

## Hermes skills

```text
/opencode
/openclaw
/multi-agent
```

Setelah install skill, jalankan `/reset` atau buat session baru di Hermes.


## Migrasi dari v1.4.x

Saat `agentstack setup`, jika stack lama terdeteksi, wizard menawarkan:

- hapus command/share `hermestools` lama;
- stop + remove container Docker `9router`;
- **tidak menghapus** data `~/.9router`.

Jadi backup/config lama tetap tersedia kalau sewaktu-waktu dibutuhkan.


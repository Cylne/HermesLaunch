<div align="center">

# 🚀 HermesLaunch

### Hermes Agent Deployment Toolkit for Linux VPS & Android Termux

**One repository — two intentionally different runtime modes.**

[![Version](https://img.shields.io/badge/version-1.4.1-blue.svg)](https://github.com/Cylne/HermesLaunch/releases)
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

# 🧠 All-In AI Stack — 9Router + Genspark + Hermes Skills

HermesLaunch v1.4.1 menambahkan **AI Stack installer** untuk VPS.

```text
Telegram
   ↓
Hermes
   ├── Existing providers (tetap utuh)
   ├── custom:9router
   │      └── OpenAI-compatible model gateway
   │
   └── Genspark toolbox
          └── search / crawl / generated GSK skill reference
```

Fresh VPS install also offers the All-In stack automatically at the end of the normal HermesLaunch wizard.

## Untuk Hermes yang sudah terinstall

Setelah repository v1.4.1 dipublish:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap-tools.sh | bash
```

Atau dari clone/ZIP:

```bash
bash toolbox/install-ai-stack.sh
```

Installer otomatis:

- backup config Hermes
- install/repair Docker
- deploy 9Router dengan binding **127.0.0.1:20128**
- persistent data di `~/.9router`
- install/update `@genspark/cli`
- install command `hermestools`
- install Hermes skills `genspark`, `router9`, `ai-stack`
- sync reference docs dari `gsk init-skills`
- health check
- guided 9Router → Hermes linking
- guided Genspark authentication
- tidak mengganti provider aktif kecuali user menyetujuinya

## External authentication yang tetap membutuhkan user

Installer tidak mencoba membypass login/OAuth atau mengedit database internal provider.

**9Router:** buka dashboard lewat SSH tunnel, Connect provider, lalu copy API key.

```bash
hermestools router dashboard
```

**Genspark:** pilih login resmi atau API key.

```bash
hermestools genspark auth
```

## Manager

```bash
hermestools
hermestools status
hermestools doctor

hermestools router status
hermestools router models
hermestools router link
hermestools router use MODEL_ID

hermestools genspark auth
hermestools genspark test
hermestools genspark sync
hermestools genspark search "latest AI agents"
```

Jika HermesLaunch v1.4.1 manager sudah terpasang:

```bash
hermeslaunch tools
```

## Telegram / Hermes skills

Setelah setup, buat session baru atau jalankan:

```text
/reset
```

Skill yang tersedia:

```text
/genspark
/router9
/ai-stack
```

> 9Router diposisikan sebagai **provider/gateway**, sedangkan Genspark diposisikan
> sebagai **external toolbox**. Keduanya tidak menghapus provider Hermes yang sudah ada.



## GitHub upload / executable-bit compatibility

HermesLaunch v1.4.1 does not require GitHub to preserve the executable bit for
repository validation. CI invokes repository scripts through `bash`; the actual
installer applies executable permissions when commands are installed into
`/usr/local/bin`.


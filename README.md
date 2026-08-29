<div align="center">

# 🚀 HermesLaunch

### Hermes Agent + Telegram + OpenCode + OpenClaw Deployment Toolkit

**Satu repository untuk memasang dan mengelola Hermes Agent dengan mudah dari VPS Linux atau Android/Termux.**

[![Version](https://img.shields.io/badge/version-1.5.1-blue.svg)](https://github.com/Cylne/HermesLaunch/releases)
[![VPS](https://img.shields.io/badge/VPS-systemd-success.svg)](https://github.com/Cylne/HermesLaunch)
[![Android](https://img.shields.io/badge/Android-Termux-black.svg)](docs/TERMUX.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Created by Reii**

[Repository](https://github.com/Cylne/HermesLaunch) ·
[Commands](docs/COMMANDS.md) ·
[Providers](docs/PROVIDERS.md) ·
[Termux Guide](docs/TERMUX.md) ·
[Security](SECURITY.md)

</div>

---

# 📌 Apa itu HermesLaunch?

HermesLaunch adalah deployment dan management wrapper independen untuk **Hermes Agent**.

Project ini dibuat agar proses berikut lebih mudah:

- install Hermes Agent;
- konfigurasi Telegram Bot;
- konfigurasi provider/model AI;
- membuat workspace project;
- menjalankan Hermes Gateway sebagai service;
- mengelola provider;
- backup/restore Hermes;
- memasang OpenCode;
- memasang OpenClaw;
- mengelola stack Hermes + OpenCode + OpenClaw dari satu manager.

Arsitektur utama:

```text
Android / Termux
      │
      │ SSH
      ▼
 Linux VPS
      │
      ▼
 HermesLaunch
      │
      ├── Hermes Agent
      │     ├── AI Provider
      │     ├── Telegram Gateway
      │     └── Workspace
      │
      ├── OpenCode
      │     └── Coding Agent CLI
      │
      └── OpenClaw
            └── Optional separate agent / Gateway
```

> HermesLaunch bukan project resmi Nous Research, OpenCode, atau OpenClaw.
> HermesLaunch hanya membantu deployment dan management tool tersebut.

---

# ✅ Yang Dipasang HermesLaunch

## Instalasi utama VPS

HermesLaunch akan menyiapkan:

```text
Hermes Agent
Hermes Telegram Gateway
HermesLaunch Manager
AI Provider configuration
Workspace project
systemd service
```

Dependency dasar yang dibutuhkan akan dipasang otomatis jika package manager VPS didukung:

```text
ca-certificates
curl
git
unzip
zip
python3
libatomic
```

Hermes Agent sendiri dipasang menggunakan installer resmi Hermes.

## Multi-Agent Stack

Saat instalasi VPS selesai, HermesLaunch akan bertanya:

```text
Install OpenCode + OpenClaw manager juga? [Y/n]
```

Jika memilih `Y`, HermesLaunch akan memasang:

```text
agentstack
OpenCode
OpenClaw
Hermes skills:
  /opencode
  /openclaw
  /multi-agent
```

Dependency tambahan yang dapat dipasang:

```text
jq
```

### OpenCode

OpenCode dipasang dari installer resmi:

```bash
curl -fsSL https://opencode.ai/install | bash
```

### OpenClaw

OpenClaw dipasang dari installer resmi dalam mode tanpa onboarding awal:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

Setelah itu onboarding dapat dijalankan melalui:

```bash
agentstack openclaw onboard
```

---

# 🖥️ Mode yang Didukung

| Mode | Hermes | Telegram | OpenCode/OpenClaw Manager | Background Runtime | Rekomendasi |
|---|:---:|:---:|:---:|---|---|
| Linux VPS + systemd | ✅ | ✅ | ✅ | systemd | ⭐ Paling direkomendasikan |
| Android Termux Native | ✅ | ✅ | Tidak menjadi target utama AgentStack | tmux | Best-effort |
| Android → SSH → VPS | ✅ | ✅ | ✅ | systemd VPS | ⭐ Cocok jika tidak punya laptop |

Jika tujuan kamu adalah bot Telegram yang hidup **24/7**, gunakan VPS.

---

# 📋 Persiapan Sebelum Install

Sebelum menjalankan installer, siapkan beberapa hal berikut.

## 1. VPS

Direkomendasikan:

```text
Ubuntu / Debian Linux
systemd aktif
root atau user dengan sudo
internet aktif
```

Cek systemd:

```bash
systemctl --version
```

Cek OS:

```bash
cat /etc/os-release
```

Cek arsitektur:

```bash
uname -m
```

---

## 2. Telegram Bot Token

Buat bot melalui Telegram:

1. buka `@BotFather`;
2. kirim `/newbot`;
3. masukkan nama bot;
4. masukkan username bot;
5. salin Bot Token.

Contoh format token:

```text
123456789:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Jangan upload atau publish Bot Token ke GitHub.**

---

## 3. Telegram Numeric User ID

HermesLaunch menggunakan numeric User ID untuk allowlist.

Kamu dapat mengambil ID menggunakan bot seperti:

```text
@userinfobot
@get_id_bot
```

Contoh:

```text
1447854280
```

Yang digunakan adalah **angka**, bukan:

```text
@username
nama akun
link Telegram
```

Multi-user dapat diisi menggunakan koma:

```text
111111111,222222222
```

---

## 4. Home Channel Chat ID

Home Channel adalah tujuan default untuk cron, reminder, atau notifikasi Hermes.

### Jika bot hanya digunakan melalui DM pribadi

Gunakan User ID kamu sendiri.

Contoh:

```text
Telegram User ID : 1447854280
Home Channel     : 1447854280
```

Saat installer menampilkan:

```text
Home Channel Chat ID [1447854280]:
```

cukup tekan **Enter**.

### Jika menggunakan grup

Chat ID grup biasanya berbentuk:

```text
-1001234567890
```

Home Channel dapat diganti kemudian dari Hermes/Telegram jika fitur tersebut tersedia pada versi Hermes yang digunakan.

---

## 5. AI Provider

Siapkan:

```text
Provider Name
API Base URL
API Key
Model ID
```

Contoh:

```text
Provider Name : MainAPI
API Base URL  : https://api.example.com/v1
API Key       : sk-xxxxxxxx
Model ID      : model-coding
```

Untuk endpoint remote, gunakan **HTTPS**.

HermesLaunch menolak endpoint remote biasa seperti:

```text
http://example.com
```

HTTP hanya diperbolehkan untuk localhost seperti:

```text
http://127.0.0.1:8000/v1
```

---

# ⭐ Cara Install yang Direkomendasikan — Android → VPS

Ini adalah jalur yang direkomendasikan jika kamu menggunakan HP Android dan tidak punya laptop.

---

## STEP 1 — Install Termux

Gunakan Termux yang masih mendapat update.

Buka Termux lalu jalankan:

```bash
pkg update -y
pkg upgrade -y
pkg install -y openssh git curl
```

Cek SSH:

```bash
ssh -V
```

---

## STEP 2 — Login ke VPS

Format:

```bash
ssh root@IP_VPS
```

Contoh:

```bash
ssh root@123.123.123.123
```

Saat pertama kali connect, biasanya muncul:

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

ketik:

```text
yes
```

lalu masukkan password VPS.

Setelah berhasil, prompt biasanya berubah menjadi seperti:

```text
root@ubuntu:~#
```

Semua command instalasi berikut dijalankan **di dalam VPS**, bukan di Termux lokal.

---

# 🚀 Install HermesLaunch

## Cara 1 — One-Line Installer

Ini adalah cara paling mudah.

Di VPS jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

`bootstrap.sh` akan mendeteksi environment.

```text
Linux VPS      → install-vps.sh
Android Termux → install-termux.sh
```

Untuk VPS, installer kemudian akan:

1. memeriksa Linux + systemd;
2. memasang dependency dasar;
3. memasang Hermes Agent jika belum ada;
4. backup config Hermes lama jika ada;
5. membuka wizard Telegram;
6. membuka wizard AI Provider;
7. membuat workspace;
8. mengetes model jika dipilih;
9. memasang Telegram Gateway sebagai system service;
10. memasang command `hermeslaunch`;
11. menawarkan OpenCode + OpenClaw AgentStack.

---

## Cara 2 — Clone Repository

Jika ingin menyimpan source HermesLaunch di VPS:

```bash
apt update -y
apt install -y git curl
git clone https://github.com/Cylne/HermesLaunch.git
cd HermesLaunch
bash install.sh
```

Jika repository sudah pernah diclone:

```bash
cd HermesLaunch
git pull
bash install.sh
```

---

# 🧙 Panduan Wizard HermesLaunch

Installer VPS menggunakan wizard 3 tahap.

---

## Tahap 1/3 — Telegram

Installer akan meminta:

```text
Bot Token dari @BotFather:
```

Paste Bot Token.

Input token disembunyikan.

Kemudian:

```text
Telegram numeric User ID:
```

Isi ID angka Telegram.

Contoh:

```text
1447854280
```

Untuk beberapa user:

```text
111111111,222222222
```

Kemudian:

```text
Home Channel Chat ID [1447854280]:
```

Jika bot digunakan di DM pribadi, tekan:

```text
Enter
```

---

## Tahap 2/3 — AI Provider

### Provider Name

Contoh:

```text
MainAPI
OpenRouter
GodenAPI
MyProvider
```

Provider Name hanya label agar mudah dikenali.

---

### API Base URL

Contoh OpenAI-compatible:

```text
https://api.example.com/v1
```

Jangan isi endpoint chat lengkap seperti:

```text
https://api.example.com/v1/chat/completions
```

Yang diminta adalah **Base URL**.

---

### API Key

Masukkan key dari provider.

Contoh:

```text
sk-xxxxxxxxxxxxxxxx
```

Secret akan disimpan pada:

```text
~/.hermes/.env
```

dengan permission yang dibatasi.

---

### API Compatibility

HermesLaunch menyediakan:

```text
1. Chat Completions (OpenAI-compatible)
2. Responses / Codex
3. Anthropic Messages
```

Jika provider mengatakan:

```text
OpenAI Compatible API
/v1/chat/completions
```

pilih:

```text
1
```

Jika tidak tahu, pilihan `1` adalah default yang paling umum.

---

### Model Discovery

Installer dapat mencoba:

```text
GET /models
```

Jika provider mendukungnya, HermesLaunch akan menampilkan daftar model.

Contoh:

```text
1. model-a
2. model-b
3. coding-model
```

Jika `/models` tidak tersedia, kamu tetap dapat memasukkan Model ID secara manual.

---

### Model ID

Model ID harus sama persis dengan ID dari provider.

Contoh:

```text
kimi-k2.5
deepseek-v3
coding-model
```

Jangan menebak Model ID jika provider memiliki dokumentasi sendiri.

---

### Context Length

Contoh:

```text
65536
131072
200000
```

Jika tidak tahu, cukup tekan:

```text
Enter
```

dan gunakan konfigurasi/default provider.

---

## Tahap 3/3 — Workspace

Workspace adalah folder default tempat Hermes mengerjakan project.

Default:

```text
/root/Reii
```

atau untuk user non-root:

```text
/home/USER/Reii
```

Jika tidak ingin mengganti, cukup tekan Enter.

HermesLaunch juga membuat:

```text
AGENTS.md
```

di workspace sebagai aturan kerja dasar dan proteksi secret.

---

# 🧪 Tes Provider

Installer akan menawarkan:

```text
Tes satu prompt AI setelah setup? Ini memakai sedikit quota/token. [Y/n]
```

Pilih:

```text
Y
```

jika ingin memastikan provider + model benar-benar dapat menjawab.

HermesLaunch akan mencoba prompt kecil dan memeriksa hasilnya.

Jika tes gagal, gateway tetap dapat dipasang sehingga konfigurasi masih bisa diperbaiki sesudah instalasi.

---

# 🤖 Install OpenCode + OpenClaw

Di akhir instalasi VPS akan muncul:

```text
Install OpenCode + OpenClaw manager juga? [Y/n]
```

Direkomendasikan pilih:

```text
Y
```

Jika memilih `Y`, HermesLaunch menjalankan AgentStack.

Setelah selesai:

```bash
agentstack status
```

atau:

```bash
hermeslaunch agents status
```

---

# ✅ Cek Setelah Instalasi

## Cek HermesLaunch

```bash
hermeslaunch version
```

## Cek Hermes Gateway

```bash
hermeslaunch status
```

## Cek log

```bash
hermeslaunch logs
```

Keluar dari log live dengan:

```text
CTRL + C
```

## Cek Hermes

```bash
hermes --version
```

## Jalankan doctor

```bash
hermeslaunch doctor
```

## Cek Multi-Agent Stack

```bash
agentstack status
```

atau:

```bash
hermeslaunch agents status
```

---

# 💬 Tes Telegram

Setelah gateway aktif:

1. buka bot Telegram yang dibuat;
2. tekan Start jika diperlukan;
3. kirim pesan.

Contoh:

```text
Halo Hermes, apakah kamu online?
```

Jika provider, Telegram token, dan allowlist benar, Hermes akan menjawab.

---

# 🛠️ Cara Menggunakan HermesLaunch

## Status

```bash
hermeslaunch status
```

Digunakan untuk mengecek Hermes Gateway.

---

## Start

```bash
hermeslaunch start
```

---

## Stop

```bash
hermeslaunch stop
```

---

## Restart

```bash
hermeslaunch restart
```

Gunakan setelah perubahan konfigurasi jika diperlukan.

---

## Logs

```bash
hermeslaunch logs
```

Pada VPS, log dibaca dari service:

```text
hermes-gateway
```

---

## Doctor

```bash
hermeslaunch doctor
```

Digunakan untuk diagnosis Hermes.

---

## Model Manager

```bash
hermeslaunch model
```

Command ini membuka model/provider wizard milik Hermes.

Gunakan untuk:

- mengganti model;
- mengganti provider;
- menambahkan provider;
- mengecek konfigurasi model.

---

## Config

```bash
hermeslaunch config
```

---

## Version

```bash
hermeslaunch version
```

---

# 🔌 HermesLaunch Provider Manager

Buka menu:

```bash
hermeslaunch provider
```

Menu:

```text
1. List custom providers
2. Add provider
3. Switch provider / model
4. Test provider
5. Remove provider
6. Back
```

---

## List Provider

```bash
hermeslaunch provider list
```

---

## Add Provider

```bash
hermeslaunch provider add
```

HermesLaunch akan membuka wizard model/provider resmi Hermes.

---

## Switch Provider

```bash
hermeslaunch provider switch
```

Gateway akan direstart setelah pergantian provider/model.

---

## Test Provider

Format:

```bash
hermeslaunch provider test PROVIDER_SLUG
```

Contoh:

```bash
hermeslaunch provider test mainapi
```

Manager akan mencoba endpoint:

```text
BASE_URL/models
```

dan tidak mencetak API key.

---

## Remove Provider

```bash
hermeslaunch provider remove PROVIDER_SLUG
```

Sebelum menghapus provider, HermesLaunch akan:

- membuat backup config;
- memastikan provider bukan provider aktif;
- meminta konfirmasi;
- menjaga provider lain;
- menjaga shared secret yang masih digunakan provider lain;
- menjalankan config check;
- restart Gateway jika konfigurasi valid.

---

# 🧠 Cara Menggunakan Hermes Agent Langsung

Selain Telegram, Hermes dapat digunakan langsung di terminal VPS.

Jalankan:

```bash
hermes
```

Atau gunakan command Hermes sesuai versi yang terpasang.

Beberapa konfigurasi utama:

```bash
hermes model
hermes tools
hermes gateway setup
hermes config
hermes doctor
```

Untuk melihat help versi Hermes yang sedang terpasang:

```bash
hermes --help
```

---

# 💻 OpenCode

OpenCode adalah coding agent CLI terpisah.

Cek status:

```bash
agentstack opencode status
```

Install/repair:

```bash
agentstack opencode install
```

Update:

```bash
agentstack opencode update
```

---

## Konfigurasi Provider OpenCode

Masuk ke folder project:

```bash
cd /root/Reii
```

Jalankan:

```bash
opencode
```

Di dalam OpenCode TUI, jalankan:

```text
/connect
```

Pilih provider dan masukkan credential.

Untuk memilih model:

```text
/models
```

OpenCode memiliki konfigurasi provider sendiri.

**API key Hermes tidak otomatis disalin ke OpenCode.**

---

## Jalankan OpenCode pada Project

Contoh:

```bash
cd /root/Reii/MyProject
opencode
```

Kemudian minta:

```text
Analyze project ini, cek error build dan berikan perbaikannya.
```

Non-interactive:

```bash
agentstack opencode run "Analyze repository ini dan jelaskan struktur project."
```

---

# 🦞 OpenClaw

OpenClaw adalah runtime/agent terpisah dari Hermes.

Install/repair:

```bash
agentstack openclaw install
```

Jalankan onboarding:

```bash
agentstack openclaw onboard
```

Onboarding akan menjalankan konfigurasi OpenClaw dan memasang daemon jika didukung.

Cek status:

```bash
agentstack openclaw status
```

Doctor:

```bash
agentstack openclaw doctor
```

Start:

```bash
agentstack openclaw start
```

Restart:

```bash
agentstack openclaw restart
```

Stop:

```bash
agentstack openclaw stop
```

Update:

```bash
agentstack openclaw update
```

---

## ⚠️ Telegram Hermes dan OpenClaw

Jika Hermes sudah menggunakan Telegram Bot:

```text
Bot A → Hermes
```

dan OpenClaw juga ingin memakai Telegram, gunakan bot berbeda:

```text
Bot B → OpenClaw
```

Jangan menjalankan dua runtime Telegram polling dengan token bot yang sama secara bersamaan.

---

# 🧩 AgentStack Manager

Buka menu:

```bash
agentstack
```

atau:

```bash
hermeslaunch agents
```

Menu utama:

```text
1. Setup / repair ALL
2. Status ALL
3. OpenCode Manager
4. OpenClaw Manager
5. Refresh Hermes skills
6. Doctor
7. Exit
```

---

## Install / Repair Semua

```bash
agentstack setup
```

Command ini menyiapkan:

```text
Hermes verification
OpenCode
OpenClaw
Hermes multi-agent skills
```

---

## Status Semua

```bash
agentstack status
```

---

## Doctor Semua

```bash
agentstack doctor
```

---

## Refresh Skills Hermes

```bash
agentstack skills
```

Skills yang dipasang:

```text
/opencode
/openclaw
/multi-agent
```

Setelah refresh skill, buat session Hermes baru atau reset session jika diperlukan agar perubahan terbaca.

---

# 🔄 Jika Hermes Sudah Terpasang Sebelumnya

Tidak perlu menghapus Hermes.

Install AgentStack saja:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap-agents.sh | bash
```

Atau dari clone repo:

```bash
cd HermesLaunch
bash agentstack/install-agentstack.sh
```

Konfigurasi Hermes lama tidak otomatis diganti oleh OpenCode/OpenClaw.

---

# 📱 Install HermesLaunch Langsung di Termux — Tanpa VPS

HermesLaunch juga memiliki Termux Mobile Mode.

> Mode ini best-effort. Android dapat menghentikan background process kapan saja.

Install:

```bash
pkg update -y
pkg install -y git curl tmux
```

Lalu:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

Installer Termux akan:

1. memasang Hermes menggunakan installer resmi;
2. membuka `hermes model`;
3. membuka `hermes gateway setup`;
4. memasang manager `hermeslaunch`;
5. membuat workspace `~/Reii`;
6. menjalankan Gateway melalui `tmux`;
7. menawarkan helper Termux:Boot jika flow mendukungnya.

---

## Command Termux

```bash
hermeslaunch status
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch logs
hermeslaunch doctor
hermeslaunch model
hermeslaunch provider
hermeslaunch gateway-setup
hermeslaunch backup
hermeslaunch restore
hermeslaunch update
hermeslaunch version
```

Runtime Termux:

```text
tmux
└── hermes gateway run
```

Bukan:

```text
systemd
```

Untuk kestabilan:

- nonaktifkan battery optimization untuk Termux;
- jangan force-stop Termux;
- izinkan background activity jika ROM menyediakan;
- gunakan wake-lock jika tersedia;
- gunakan Termux:Boot bila ingin mencoba start otomatis.

Untuk uptime 24/7, tetap gunakan VPS.

---

# ♻️ Update

Ada **dua jenis update** yang berbeda.

---

## 1. Update Hermes Agent

Command:

```bash
hermeslaunch update
```

Command ini menjalankan update Hermes Agent dengan backup.

**Command ini tidak melakukan `git pull` repository HermesLaunch.**

---

## 2. Update HermesLaunch

Jika menggunakan clone Git:

```bash
cd ~/HermesLaunch
git pull
bash install.sh
```

Sesuaikan path jika repository berada di folder lain.

Atau cukup jalankan bootstrap terbaru:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

Installer akan membuat backup konfigurasi Hermes yang relevan sebelum konfigurasi ulang.

---

## Update OpenCode

```bash
agentstack opencode update
```

---

## Update OpenClaw

```bash
agentstack openclaw update
```

---

# 💾 Backup & Restore

## Backup

Default:

```bash
hermeslaunch backup
```

Atau tentukan nama file:

```bash
hermeslaunch backup ~/hermes-backup.zip
```

Full backup Hermes dapat berisi:

```text
API keys
Telegram Bot Token
config
session data
credential lain
```

Jangan upload backup ke repository public.

---

## Restore

```bash
hermeslaunch restore ~/hermes-backup.zip
```

Saat restore, Gateway dihentikan sementara dan dijalankan lagi setelah import.

---

# 🧯 Troubleshooting

## `hermeslaunch: command not found`

Cek:

```bash
command -v hermeslaunch
```

Pada VPS normal seharusnya:

```text
/usr/local/bin/hermeslaunch
```

Coba:

```bash
hash -r
```

atau login ulang ke SSH.

Jika masih tidak ada, jalankan installer lagi.

---

## `hermes: command not found`

Cek:

```bash
command -v hermes
```

Coba reload shell:

```bash
source ~/.bashrc
```

Lalu:

```bash
hermes --version
```

Jika tetap gagal, jalankan kembali HermesLaunch.

---

## Gateway tidak aktif

Cek:

```bash
hermeslaunch status
```

Restart:

```bash
hermeslaunch restart
```

Lihat log:

```bash
hermeslaunch logs
```

Cek systemd:

```bash
systemctl status hermes-gateway --no-pager
```

---

## Bot Telegram tidak membalas

Cek secara berurutan:

```bash
hermeslaunch status
hermeslaunch logs
hermeslaunch doctor
```

Pastikan:

```text
Bot Token benar
Telegram User ID berupa angka
User ID masuk allowlist
provider dapat menjawab
Model ID benar
Gateway berjalan
```

Tes Hermes tanpa Telegram:

```bash
hermes
```

Jika Hermes CLI tidak dapat menjawab, perbaiki provider/model terlebih dahulu.

---

## Provider gagal

Buka:

```bash
hermeslaunch model
```

atau:

```bash
hermeslaunch provider
```

Cek:

```text
Base URL
API Key
Compatibility mode
Model ID
```

Untuk custom provider:

```bash
hermeslaunch provider list
```

lalu:

```bash
hermeslaunch provider test PROVIDER_SLUG
```

---

## OpenCode tidak ditemukan

Cek:

```bash
agentstack opencode status
```

Repair:

```bash
agentstack opencode install
```

Kemudian:

```bash
opencode --version
```

---

## OpenClaw tidak ditemukan

Repair:

```bash
agentstack openclaw install
```

Kemudian:

```bash
openclaw --version
```

Onboard:

```bash
agentstack openclaw onboard
```

---

## OpenClaw Gateway bermasalah

```bash
agentstack openclaw status
agentstack openclaw doctor
agentstack openclaw restart
```

---

## AgentStack belum terinstall

Jika:

```bash
hermeslaunch agents
```

mengatakan manager belum tersedia, jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap-agents.sh | bash
```

---

# 🔐 Security

Jangan pernah commit file berikut:

```text
.env
API key
Telegram Bot Token
password
private key
Hermes full backup
```

Hermes Agent dengan terminal tools berjalan menggunakan privilege user OS tempat Hermes dijalankan.

Jika Hermes dijalankan sebagai:

```text
root
```

maka agent berpotensi menjalankan command dengan privilege tinggi.

Gunakan VPS khusus jika memungkinkan dan hindari menyimpan project sensitif yang tidak berhubungan pada workspace agent.

Workspace default HermesLaunch memiliki `AGENTS.md` yang mengingatkan agent agar:

- bekerja di workspace;
- tidak menyentuh service/project lain tanpa instruksi;
- tidak mencetak secret;
- meminta konfirmasi sebelum operasi destruktif di luar workspace.

---

# 📂 Lokasi Penting

Default Hermes Home:

```text
~/.hermes
```

Config:

```text
~/.hermes/config.yaml
```

Environment/secret:

```text
~/.hermes/.env
```

Default workspace VPS root:

```text
/root/Reii
```

Manager VPS:

```text
/usr/local/bin/hermeslaunch
```

AgentStack manager:

```text
/usr/local/bin/agentstack
```

AgentStack shared data:

```text
/usr/local/share/hermeslaunch-agentstack
```

---

# 📁 Struktur Repository

```text
HermesLaunch/
├── install.sh
├── install-vps.sh
├── install-termux.sh
├── bootstrap.sh
├── bootstrap-agents.sh
├── README.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
│
├── bin/
│   └── hermeslaunch
│
├── agentstack/
│   ├── agentstack
│   ├── install-agentstack.sh
│   └── skills/
│
├── assets/
│   └── installation-complete.png
│
├── docs/
│   ├── COMMANDS.md
│   ├── MIGRATION.md
│   ├── MULTI_AGENT.md
│   ├── PROVIDERS.md
│   ├── PUBLISHING.md
│   └── TERMUX.md
│
└── scripts/
    ├── release.sh
    ├── selftest.sh
    └── set-repo.sh
```

---

# ⚡ Quick Command Cheat Sheet

## HermesLaunch

```bash
hermeslaunch status
hermeslaunch logs
hermeslaunch start
hermeslaunch stop
hermeslaunch restart
hermeslaunch doctor
hermeslaunch model
hermeslaunch provider
hermeslaunch config
hermeslaunch backup
hermeslaunch restore FILE.zip
hermeslaunch update
hermeslaunch version
```

## AgentStack

```bash
agentstack
agentstack setup
agentstack status
agentstack doctor
agentstack skills
```

## OpenCode

```bash
agentstack opencode install
agentstack opencode update
agentstack opencode status
agentstack opencode tui .
agentstack opencode run "PROMPT"
```

## OpenClaw

```bash
agentstack openclaw install
agentstack openclaw onboard
agentstack openclaw status
agentstack openclaw doctor
agentstack openclaw start
agentstack openclaw restart
agentstack openclaw stop
agentstack openclaw update
```

---

# 📚 Official Documentation

Hermes Agent:

```text
https://hermes-agent.nousresearch.com/docs/
```

OpenCode:

```text
https://opencode.ai/docs
```

OpenClaw:

```text
https://docs.openclaw.ai/
```

---

# 🤝 Credits

### HermesLaunch

Created by **Reii**

Repository:

```text
https://github.com/Cylne/HermesLaunch
```

Hermes Agent, OpenCode, dan OpenClaw adalah project terpisah dengan maintainer masing-masing.

<div align="center">

## HermesLaunch

**Hermes for the main agent. OpenCode for coding. OpenClaw when you need a separate runtime.**

**Created by Reii**

</div>

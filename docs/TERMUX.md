# 📱 Tutorial Termux — HermesLaunch

> HermesLaunch v1.1.0 menggunakan **Termux sebagai remote control untuk VPS**, bukan menjalankan gateway production langsung di Android.

Hermes Agent memang memiliki dukungan Android/Termux, tetapi statusnya Tier 2. Untuk bot Telegram 24/7, VPS Linux + systemd lebih stabil.

## 1. Install Termux

Gunakan build Termux yang masih aktif (misalnya F-Droid/GitHub resmi Termux), lalu buka aplikasinya.

## 2. Update package

```bash
pkg update -y && pkg upgrade -y
```

## 3. Install SSH + curl + git

```bash
pkg install -y openssh curl git
```

Opsional, aktifkan akses storage:

```bash
termux-setup-storage
```

## 4. Login ke VPS

```bash
ssh root@IP_VPS
```

Contoh:

```bash
ssh root@203.0.113.10
```

Masukkan password VPS saat diminta.

> Kalau prompt berubah dari `~ $` menjadi `root@nama-vps:~#`, berarti kamu sudah berada di VPS.

## 5. Jalankan HermesLaunch di VPS

Setelah repo dipublish:

```bash
curl -fsSL https://raw.githubusercontent.com/__GITHUB_REPO__/main/bootstrap.sh | bash
```

Wizard akan meminta:

1. Telegram Bot Token
2. Telegram numeric User ID
3. Nama provider
4. Base URL API
5. API Key
6. API compatibility mode
7. Model ID
8. Context length (opsional)
9. Workspace project

## 6. Setelah selesai

Cek:

```bash
hermeslaunch status
```

Pantau log:

```bash
hermeslaunch logs
```

Restart:

```bash
hermeslaunch restart
```

## 7. Ambil project VPS ke Android

Contoh project berada di:

```text
/root/Reii/NamaProject
```

Keluar dari SSH:

```bash
exit
```

Pastikan prompt Termux kembali menjadi:

```text
~ $
```

Kemudian:

```bash
scp -r root@IP_VPS:/root/Reii/NamaProject ~/storage/downloads/
```

Hasilnya masuk ke folder **Download** Android.

Untuk ZIP:

```bash
scp root@IP_VPS:/root/Reii/NamaProject.zip ~/storage/downloads/
```

## 8. Backup Hermes dari VPS ke Android

Di VPS:

```bash
hermeslaunch backup ~/hermes-backup.zip
```

Keluar dari SSH lalu:

```bash
scp root@IP_VPS:~/hermes-backup.zip ~/storage/downloads/
```

⚠️ Backup penuh Hermes berisi API key, Bot Token, auth, session, memory, dan konfigurasi. Jangan upload ke tempat publik.

## 9. Pindah ke VPS baru

Upload backup dari Android:

```bash
scp ~/storage/downloads/hermes-backup.zip root@IP_VPS_BARU:~/
```

Login:

```bash
ssh root@IP_VPS_BARU
```

Install HermesLaunch, lalu:

```bash
hermeslaunch restore ~/hermes-backup.zip
```

Selesai.

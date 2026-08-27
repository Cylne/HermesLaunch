# 🚀 Publishing HermesLaunch ke GitHub

## 1. Tentukan repo

Contoh:

```text
username: reii-dev
repo: HermesLaunch
```

Dari folder project jalankan:

```bash
./scripts/set-repo.sh reii-dev/HermesLaunch
```

Script ini mengganti placeholder `__GITHUB_REPO__` pada README, bootstrap, dan docs.

## 2. Cek sebelum publish

```bash
bash -n install.sh
bash -n bootstrap.sh
bash -n scripts/*.sh
```

Pastikan tidak ada secret:

```bash
git grep -nE 'sk-[A-Za-z0-9]|BOT_TOKEN=|API_KEY=.*[^<]'
```

Review hasilnya manual; beberapa contoh dokumentasi dapat cocok regex.

## 3. Init Git

```bash
git init
git add .
git commit -m "release: HermesLaunch v1.1.0"
git branch -M main
```

## 4. Hubungkan repo

```bash
git remote add origin https://github.com/USERNAME/HermesLaunch.git
git push -u origin main
```

## 5. Build release archive

```bash
./scripts/release.sh
```

Hasil ada di:

```text
dist/
```

Upload file ZIP, TAR.GZ, dan `CHECKSUMS.sha256` ke GitHub Release `v1.1.0`.

## 6. One-line installer user

Setelah repo public:

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/HermesLaunch/main/bootstrap.sh | bash
```

Untuk keamanan lebih tinggi, user dapat clone repo dan inspect script sebelum menjalankan.

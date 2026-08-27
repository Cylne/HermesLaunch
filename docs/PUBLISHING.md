# 🚀 Publishing HermesLaunch

Canonical repository:

```text
https://github.com/Cylne/HermesLaunch.git
```

## Push

```bash
git init
git add .
git commit -m "release: HermesLaunch v1.2.2"
git branch -M main
git remote add origin https://github.com/Cylne/HermesLaunch.git
git push -u origin main
```

If the remote already exists:

```bash
git remote set-url origin https://github.com/Cylne/HermesLaunch.git
git push
```

## Public install command

```bash
curl -fsSL https://raw.githubusercontent.com/Cylne/HermesLaunch/main/bootstrap.sh | bash
```

`bootstrap.sh` automatically dispatches:

```text
VPS    → install-vps.sh
Termux → install-termux.sh
```

## Release

```bash
./scripts/release.sh
```

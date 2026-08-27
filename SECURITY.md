# Security Policy

## Credential handling

HermesLaunch menyimpan Telegram Bot Token dan provider API key di:

```text
~/.hermes/.env
```

File dipaksa ke permission `0600`.

## Access control

Installer **mewajibkan** `TELEGRAM_ALLOWED_USERS`. Open-access Telegram tidak ditawarkan.

## Network

Provider remote wajib HTTPS. HTTP hanya diterima untuk loopback (`127.0.0.1`/`localhost`).

## Root access

Hermes dapat menjalankan terminal tools. Jika gateway dijalankan sebagai root, Hermes secara efektif memiliki akses root ke VPS.

Untuk server pribadi ini praktis. Untuk server shared/production sensitif, gunakan Linux user khusus dengan privilege minimum.

## Backups

`hermes backup` penuh membawa credential. Backup adalah secret.

## Responsible disclosure

Jangan kirim `.env`, bot token, API key, private key, password VPS, atau Hermes full backup saat membuat bug report.

Credits: Reii

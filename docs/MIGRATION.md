# 🚚 VPS Migration

Hermes menyediakan backup/import resmi. HermesLaunch memberi wrapper agar lebih mudah.

## VPS lama

```bash
hermeslaunch backup ~/hermes-migration.zip
```

## Copy

```bash
scp ~/hermes-migration.zip root@IP_VPS_BARU:~/
```

## VPS baru

Install HermesLaunch terlebih dahulu, lalu:

```bash
hermeslaunch restore ~/hermes-migration.zip
```

## Apa yang ikut?

Full Hermes backup dapat mencakup config, `.env`, auth, session, skills, memory, cron, dan data Hermes lainnya.

**Anggap backup sebagai secret.** Jangan upload ke GitHub, Telegram group, Google Drive publik, atau hosting tanpa proteksi.

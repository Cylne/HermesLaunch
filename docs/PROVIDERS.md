# 🔌 Provider Manager

HermesLaunch v1.3.0 memiliki **Provider Manager** untuk custom providers.

> Provider Manager hanya mengelola provider yang berada di bagian `providers:` pada konfigurasi Hermes. Built-in providers Hermes tidak dihapus.

## Open menu

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

## Direct commands

```bash
hermeslaunch provider list
hermeslaunch provider add
hermeslaunch provider switch
hermeslaunch provider test
hermeslaunch provider test provider-slug
hermeslaunch provider remove
hermeslaunch provider remove provider-slug
```

## Safe provider removal

Sebelum menghapus provider, HermesLaunch akan:

1. memastikan provider benar-benar custom provider;
2. mengecek apakah provider sedang aktif;
3. jika aktif, meminta user memilih provider/model pengganti terlebih dahulu;
4. membuat backup `config.yaml` dan `.env`;
5. menghapus hanya konfigurasi provider yang dipilih;
6. hanya menghapus API key otomatis jika key tersebut dibuat khusus oleh HermesLaunch (`HERMESLAUNCH_*_API_KEY`);
7. mempertahankan key generik/shared seperti `OPENAI_API_KEY`;
8. menjalankan `hermes config check`;
9. restart gateway hanya setelah config valid.

Backup disimpan di:

```text
~/.hermes/backups/hermeslaunch-provider-YYYYMMDD-HHMMSS/
```

## Provider testing

`hermeslaunch provider test` melakukan connectivity check ringan ke:

```text
GET <provider-base-url>/models
```

API key tidak dicetak ke terminal.

Beberapa provider tidak menyediakan `/models`, jadi response non-2xx belum tentu berarti provider rusak.

## Add / switch provider

HermesLaunch menggunakan wizard resmi Hermes:

```bash
hermes model
```

Ini menjaga compatibility dengan provider/model baru yang ditambahkan Hermes di masa depan.

## Example custom provider

```text
Provider : 9Router
Base URL : http://127.0.0.1:20128/v1
Mode     : Chat Completions
Model    : <model-id>
```

Remote provider sebaiknya menggunakan HTTPS.

Repository: https://github.com/Cylne/HermesLaunch.git

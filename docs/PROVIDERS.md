# 🔌 Provider Guide

HermesLaunch fokus pada endpoint yang kompatibel dengan OpenAI/Responses/Anthropic proxy.

## OpenAI-compatible

Pilih:

```text
API Compatibility: 1
```

Contoh bentuk URL:

```text
https://provider.example.com/v1
```

HermesLaunch akan mencoba membaca:

```text
GET <base-url>/models
```

dan menampilkan maksimal 25 Model ID.

## 9Router lokal

Jika 9Router berjalan di VPS yang sama:

```text
Provider : 9Router
Base URL : http://127.0.0.1:20128/v1
Mode     : Chat Completions
```

HTTP tanpa TLS hanya diizinkan HermesLaunch untuk `localhost` / `127.0.0.1`.

## Ganti model setelah install

Dari Telegram:

```text
/model
```

Dari terminal VPS:

```bash
hermeslaunch model
```

## Tambah provider lain

Gunakan wizard resmi Hermes:

```bash
hermeslaunch model
```

Hermes juga mendukung named custom providers dan banyak built-in provider.

## Catatan keamanan

- Jangan menaruh API key di README.
- Jangan commit `~/.hermes/.env`.
- Jangan mengirim API key ke chat publik.
- Gunakan HTTPS untuk provider remote.

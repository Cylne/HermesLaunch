# HermesLaunch All-In AI Stack

## Goal

Keep the architecture simple:

```text
Telegram -> Hermes
             ├─ model: existing provider or custom:9router
             └─ tools: Genspark CLI
```

## Existing installation

```bash
bash toolbox/install-ai-stack.sh
```

## Main command

```bash
hermestools
```

## 9Router

HermesTools creates the container on localhost only:

```text
127.0.0.1:20128 -> container:20128
```

Dashboard:

```bash
hermestools router dashboard
```

Link after obtaining a 9Router API key:

```bash
hermestools router link
```

The link action creates a named Hermes custom provider `custom:9router`.
It does not make it active unless explicitly approved.

## Genspark

```bash
hermestools genspark auth
hermestools genspark test
hermestools genspark sync
```

Hermes uses the `genspark` skill to invoke the GSK CLI.

## Security

- Secrets are never committed to this project.
- Hermes config and env are backed up before provider changes.
- Genspark key file uses mode 600.
- 9Router dashboard is not publicly exposed by the default installer.
- Unrelated VPS services are not stopped/restarted.
- Only `hermes-gateway.service` may be restarted after a valid Hermes config change.

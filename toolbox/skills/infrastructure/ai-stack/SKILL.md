---
name: ai-stack
description: Operate the HermesLaunch AI stack consisting of Hermes, 9Router, and Genspark with clear separation between model routing and external tools.
version: 1.0.0
metadata:
  hermes:
    tags: [hermes, ai-stack, orchestration]
    category: infrastructure
---

# HermesLaunch AI Stack

Use this mental model:

```text
Telegram
  -> Hermes
       -> Model inference: existing provider OR custom:9router
       -> Research/tools: Genspark via gskh
```

9Router is optional and must not erase existing providers.
Genspark is primarily an external toolbox.

Check the whole stack:

```bash
hermestools status
```

Run diagnostics:

```bash
hermestools doctor
```

For Genspark tasks load the `genspark` skill.
For 9Router administration load the `router9` skill.

Never reveal credentials or `.env` contents.

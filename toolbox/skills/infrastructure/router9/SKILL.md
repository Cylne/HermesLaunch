---
name: router9
description: Manage the local 9Router instance and use it as an optional named custom AI provider for Hermes without removing existing providers.
version: 1.0.0
metadata:
  hermes:
    tags: [9router, llm, provider, routing, infrastructure]
    category: infrastructure
---

# 9Router Manager

## Architecture

9Router is an LLM router/provider gateway. It is not the primary Hermes tool
runtime. Hermes talks to it as a named custom OpenAI-compatible provider:

```text
Hermes -> custom:9router -> http://127.0.0.1:20128/v1
```

Existing Hermes providers must remain untouched.

## Safe management commands

Status:

```bash
hermestools router status
```

Models:

```bash
hermestools router models
```

Recent logs:

```bash
hermestools router logs 100
```

Restart only 9Router:

```bash
hermestools router restart
```

Dashboard tunnel instructions:

```bash
hermestools router dashboard
```

Link 9Router to Hermes interactively:

```bash
hermestools router link
```

Switch Hermes to a known 9Router model only when the user asks:

```bash
hermestools router use MODEL_ID
```

## Safety rules

- Never expose port 20128 publicly just for convenience.
- Never print the 9Router API key.
- Do not remove or overwrite unrelated Hermes providers.
- Do not modify unrelated services/projects on the VPS.
- Ask before updating the 9Router image or changing the active Hermes model.

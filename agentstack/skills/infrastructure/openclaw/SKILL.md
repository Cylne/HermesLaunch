---
name: openclaw
description: Manage an installed OpenClaw instance and its Gateway from Hermes without conflating OpenClaw with Hermes itself.
version: 1.0.0
metadata:
  hermes:
    tags: [openclaw, gateway, agent, infrastructure]
    category: infrastructure
---

# OpenClaw Manager

OpenClaw is a separate agent runtime and Gateway.

Status:

```bash
agentstack openclaw status
```

Doctor:

```bash
agentstack openclaw doctor
```

Gateway:

```bash
agentstack openclaw start
agentstack openclaw restart
agentstack openclaw stop
```

Onboarding, only when the user asks:

```bash
agentstack openclaw onboard
```

Important: if Hermes already uses a Telegram bot token, do not reuse that same
token for OpenClaw at the same time. Use a different bot or skip the channel.

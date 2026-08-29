---
name: multi-agent
description: Operate Hermes, OpenCode, and OpenClaw with clear role separation.
version: 1.0.0
metadata:
  hermes:
    tags: [hermes, opencode, openclaw, orchestration]
    category: infrastructure
---

# Multi-Agent Stack

Recommended architecture:

```text
Telegram -> Hermes
              -> OpenCode for optional coding delegation

OpenClaw -> optional separate Gateway/runtime
```

Do not route Hermes inference through OpenCode or OpenClaw by default.

Whole-stack status:

```bash
agentstack status
```

Diagnostics:

```bash
agentstack doctor
```

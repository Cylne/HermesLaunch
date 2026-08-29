---
name: opencode
description: Use OpenCode as a dedicated coding agent/automation tool from Hermes for repository analysis, implementation, refactors, and code tasks.
version: 1.0.0
metadata:
  hermes:
    tags: [opencode, coding, repository, automation]
    category: coding
---

# OpenCode

OpenCode is installed as a separate coding CLI.

Check:

```bash
agentstack opencode status
```

For a non-interactive coding task, run inside the requested project directory:

```bash
opencode run "PROMPT"
```

For interactive use:

```bash
opencode .
```

Configure model/provider inside OpenCode, normally with `/connect`.

Safety:
- Work only in the project/path the user requested.
- Do not use auto-approval unless the user explicitly requests unattended execution.
- Review destructive changes.
- Never expose provider credentials.

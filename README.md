# claude-code-config

> ## 🚀 Migrated to Flow — [GitHub](https://github.com/gmickel/gmickel-claude-marketplace) · [Website](https://mickel.tech/apps/flow)
>
> **All commands and agents from this repo are now part of Flow** — plan first, work second. 4 commands, 6 agents, 6 skills.
>
> Most agent failures aren't capability—they're process: coding before understanding the codebase, reinventing existing patterns, forgetting the plan mid-implementation. Flow fixes this with structured research, explicit plan reuse, and plan re-read between tasks.
>
> ```bash
> /plugin marketplace add https://github.com/gmickel/gmickel-claude-marketplace
> /plugin install flow
> ```
>
> **Highlights:**
> - **Parallel research agents** — repo-scout (fast) or context-scout (deep via rp-cli)
> - **Gap analysis** — catches edge cases and missing flows before you code
> - **Auto-reviews** — Carmack-level plan + impl reviews via cross-model RepoPrompt chat
> - **Beads integration** — optional dependency-aware issue tracking
> - **~100 tokens startup** — progressive disclosure, full logic loads on-demand
>
> Legacy versions still available in [`legacy/`](legacy/) — install with `--legacy` flag.

---

My Claude Code setup: skills and commands. **For the full workflow, use Flow above.**

## Installation

```bash
# curl (requires jq)
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash

# or clone
git clone git@github.com:gmickel/claude-code-config.git && cd claude-code-config && ./install.sh
```

<details>
<summary>More options</summary>

**Selective install:**
```bash
curl -fsSL .../install-remote.sh | bash -s -- --skills   # skills only
curl -fsSL .../install-remote.sh | bash -s -- --commands # commands only
curl -fsSL .../install-remote.sh | bash -s -- --legacy   # legacy commands/agents
```

**Windows (PowerShell):**
```powershell
git clone git@github.com:gmickel/claude-code-config.git
cd claude-code-config
.\install.ps1
```

**Security-conscious:**
```bash
curl -fsSL .../install-remote.sh -o install.sh
less install.sh  # inspect
bash install.sh
```

All scripts copy to `~/.claude/` non-destructively. Existing files are never overwritten.

</details>

---

## Why This Setup

I've tried complex configurations. This simple approach works better:

| Component | Purpose |
|-----------|---------|
| **Opus 4.5** | Development |
| **GPT-5.2 High** | Reviews via [RepoPrompt](https://repoprompt.com) |
| **Skills/Commands** | Replace MCP clients (~15k tokens saved) |
| **Autonomous loops** | Review → fix → re-review until ship-ready |

The key: delegate heavy work to external tools with full codebase context, keep the main conversation lean.

---

## What's Included

### Commands

| Command | Description |
|---------|-------------|
| `/pseo` | Programmatic SEO improvements |
| `/rp-plan-review` | ⚠️ **Legacy** — use [`/flow:plan-review`](#-migrated-to-flow) |
| `/rp-impl-review` | ⚠️ **Legacy** — use [`/flow:impl-review`](#-migrated-to-flow) |

Legacy commands require `--legacy` flag to install.

### Skills

| Skill | Description |
|-------|-------------|
| [oracle](https://github.com/steipete/oracle) | Bundle prompts + files for second-model review |
| [convex](https://convex.dev) | Convex backend patterns — based on [Convex Chef](https://chef.convex.dev), customized to make Convex dev less painful |
| [sheets-cli](https://github.com/gmickel/sheets-cli) | Google Sheets automation |
| [outlookctl](https://github.com/gmickel/outlookctl) | Outlook calendar/email automation |

---

## Prerequisites

**rp-cli** — Legacy commands (`--legacy`) require [RepoPrompt CLI](https://repoprompt.com/docs#s=rp-cli&ss=cli-guide), bundled with RepoPrompt.

---

## Related

**[Flow](https://github.com/gmickel/gmickel-claude-marketplace)** — Plan first, work second. 4 commands, 6 agents, 6 skills. ([Website](https://mickel.tech/apps/flow))
```bash
/plugin marketplace add https://github.com/gmickel/gmickel-claude-marketplace
/plugin install flow
```

**[compound-engineering](https://github.com/EveryInc/compound-engineering-plugin)** — Full-featured multi-agent workflows, parallel processing, specialized reviewers
```bash
/plugin marketplace add every-inc/compound-engineering
```

**[frontend-design](https://github.com/anthropics/claude-code-plugins)** — Frontend generation that doesn't look like AI slop (Anthropic)
```bash
/plugin marketplace add anthropics/claude-code
/plugin install frontend-design@claude-code-plugins
```

**[Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills)** — For project-level domain-specific skills

---

## Compatibility

These skills, commands, and agents follow common conventions and should work with other AI coding tools:

- [OpenAI Codex](https://developers.openai.com/codex/skills/create-skill/) — [skills](https://developers.openai.com/codex/skills/create-skill/), [commands](https://developers.openai.com/codex/guides/slash-commands/)
- [OpenCode](https://opencode.ai) — [skills](https://opencode.ai/docs/skills/), [commands](https://opencode.ai/docs/commands/), [agents](https://opencode.ai/docs/agents/)
- [Factory](https://docs.factory.ai/cli/configuration/skills) — skills

---

## Credits

- [@pvncher](https://x.com/pvncher) — [RepoPrompt](https://repoprompt.com)
- [@steipete](https://x.com/steipete) — [Oracle](https://github.com/steipete/oracle)

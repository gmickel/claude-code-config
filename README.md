# claude-code-config

My Claude Code setup: skills, commands, and agents for fast, high-quality development.

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
curl -fsSL .../install-remote.sh | bash -s -- --agents   # agents only
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
| `/rp-plan-review` | Carmack-level plan review via RepoPrompt |
| `/rp-impl-review` | Carmack-level code review of current branch |

Both use `rp-cli` to build context and send to GPT-5.2 High for deep analysis.

```bash
/rp-plan-review docs/plan/auth-refactor.md focus on security
/rp-impl-review focus on auth changes, ignore styling
```

### Skills

| Skill | Description |
|-------|-------------|
| [oracle](https://github.com/steipete/oracle) | Bundle prompts + files for second-model review |
| [convex](https://convex.dev) | Convex backend patterns — based on [Convex Chef](https://chef.convex.dev), customized to make Convex dev less painful |
| [sheets-cli](https://github.com/gmickel/sheets-cli) | Google Sheets automation |
| [outlookctl](https://github.com/gmickel/outlookctl) | Outlook calendar/email automation |

### Agents

| Agent | Description |
|-------|-------------|
| rp-explorer | Token-efficient codebase exploration via RepoPrompt codemaps |

---

## Command Chaining

Chain commands in a single prompt for autonomous workflows:

```
/workflows:plan [feature] then review via /rp-plan-review and implement improvements
```

Claude will plan → review → fix → re-review → iterate until done:

```
Plan Review Complete: SHIP

Plan: plans/t8-search-commands.md (v3-final)
Issues Addressed: v1 (11 issues), v2 (5 issues) — all resolved
Ready to implement.
```

---

## Prerequisites

**rp-cli** — Most commands depend on [RepoPrompt CLI](https://repoprompt.com/docs#s=rp-cli&ss=cli-guide):

```bash
npm install -g @nicepkg/rp-cli
```

---

## Related

**[compound-engineering](https://github.com/EveryInc/compound-engineering-plugin)** — Multi-agent workflows, parallel processing
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

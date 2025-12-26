# Claude Config

Personal Claude Code configuration for high-velocity, high-quality development.

## Installation

### Quick Install (curl)

Requires `jq` (`brew install jq` or `apt install jq`).

```bash
# Install everything
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash

# Or pick what you want
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash -s -- --skills
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash -s -- --commands
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash -s -- --agents
```

**Security-conscious install** (inspect before running):
```bash
curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh -o install.sh
less install.sh  # review
bash install.sh
```

### Clone & Install

**macOS / Linux / WSL:**
```bash
git clone git@github.com:gmickel/claude-code-config.git
cd claude-code-config
./install.sh
```

**Windows (PowerShell):**
```powershell
git clone git@github.com:gmickel/claude-code-config.git
cd claude-code-config
.\install.ps1
```

All scripts non-destructively copy to `~/.claude/`. Existing files are never overwritten.

## Philosophy

There are far more complicated setups out there—I've experimented with many. This relatively simple configuration works extremely well for me:

- **Opus 4.5** for development
- **GPT-5.2 High** for reviews via [RepoPrompt](https://repoprompt.com)
- **Skills and commands** instead of MCP clients (saves ~15k tokens per session)
- **Autonomous review loops**—Claude does reviews, re-reviews, iterates until ship-ready

The key insight: delegate heavy-lifting to external tools with full codebase context, keep the main conversation lean.

## Prerequisites

### rp-cli (RepoPrompt CLI)

Most commands here depend on [rp-cli](https://repoprompt.com/docs#s=rp-cli&ss=cli-guide). Install via RepoPrompt app or npm:

```bash
npm install -g @nicepkg/rp-cli
```

rp-cli lets Claude Code call RepoPrompt without bloating context. The CLI accepts window/tab params for concurrent agent use.

## Commands

Slash commands that delegate to external reviewers with full codebase context.

### `/rp-plan-review`

Carmack-level implementation plan review.

```
/rp-plan-review docs/plan/auth-refactor.md focus on security
```

1. Agent reads plan file, finds related PRD/issues
2. Calls `builder` to select relevant codebase files
3. Sends review prompt to RepoPrompt chat (GPT-5.2 High)
4. Returns deep architectural feedback

### `/rp-impl-review`

Carmack-level code review of current branch changes.

```
/rp-impl-review focus on the auth changes, ignore styling
```

1. Agent gets git diff, identifies changed files
2. Calls `builder` to select changed files + dependencies
3. Sends review prompt covering correctness, simplicity, DRY, edge cases, security
4. Returns thorough implementation feedback

## Skills

Auto-triggered capabilities based on conversation context.

### oracle

Use [@steipete/oracle](https://github.com/steipete/oracle) to bundle prompts + files for second-model review. Supports API or browser automation with GPT-5.2 Pro, Claude, Gemini.

```bash
npx -y @steipete/oracle --engine browser --model gpt-5.2-pro -p "<task>" --file "src/**"
```

### convex

Convex backend development patterns—validators, indexes, actions, queries, mutations, file storage, scheduling, React hooks. Auto-loads when writing Convex code.

### sheets-cli

Read, write, update Google Sheets via [sheets-cli](https://github.com/gmickel/sheets-cli). Not dev-specific—just something I use at work a lot.

```bash
sheets-cli read table --spreadsheet <id> --sheet "Projects" --limit 100
sheets-cli update key --spreadsheet <id> --sheet "Tasks" --key-col "ID" --key "TASK-42" --set '{"Status":"Done"}'
```

### outlookctl

Outlook calendar/email automation via [outlookctl](https://github.com/gmickel/outlookctl). Used in specific work contexts.

---

*Note: I have more domain-specific skills at the project level. See [Claude Code skills docs](https://docs.anthropic.com/en/docs/claude-code/skills).*

## Agents

Subagents spawned via the Task tool.

### rp-explorer

Token-efficient codebase exploration using RepoPrompt codemaps and slices. Uses `structure` for API signatures (10x fewer tokens than full files), returns summarized findings.

## Command Chaining

Claude Code commands can be chained in a single prompt:

```
/workflows:plan [feature description] then review via /rp-plan-review and implement all improvements
```

Claude will autonomously:
1. Create the plan
2. Review it
3. Address review feedback
4. Re-review
5. Iterate until ship-ready

Example output after autonomous iteration:

```
Plan Review Complete: SHIP

Plan: plans/t8-search-commands.md (v3-final)

Issues Addressed:
v1 Review (11 issues): 2 Critical, 6 Major, 3 Minor
v2 Review (5 new issues): All resolved

Ready to implement.
```

## Related Tools (Not in This Repo)

### compound-engineering plugin

Multi-agent workflows, parallel processing, specialized reviewers. [GitHub](https://github.com/EveryInc/compound-engineering-plugin)

```bash
/plugin marketplace add every-inc/compound-engineering
```

Key commands:
- `/workflows:plan` — Transform feature descriptions into structured plans
- `/workflows:work` — Execute plans efficiently

### frontend-design plugin

Frontend generation that doesn't look like AI slop. By Anthropic.

```bash
/plugin marketplace add anthropics/claude-code
/plugin install frontend-design@claude-code-plugins
```

## Credits

- **[@pvncher](https://x.com/pvncher)** — [RepoPrompt](https://repoprompt.com) and rp-cli
- **[@steipete](https://x.com/steipete)** — [Oracle CLI](https://github.com/steipete/oracle)

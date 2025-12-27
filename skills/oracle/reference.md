# Oracle CLI Reference

Complete reference for @steipete/oracle CLI.

## Main Use Case (Browser, GPT-5.2 Pro)

Default workflow: `--engine browser` with GPT-5.2 Pro in ChatGPT. This is the "human in the loop" path: can take ~10 minutes to ~1 hour; expect a stored session you can reattach to.

Recommended defaults:
- Engine: browser (`--engine browser`)
- Model: GPT-5.2 Pro (`--model gpt-5.2-pro` or `--model "5.2 Pro"`)
- Attachments: directories/globs + excludes; avoid secrets

## Commands

Show help:
```bash
npx -y @steipete/oracle --help
```

Preview (no tokens):
```bash
npx -y @steipete/oracle --dry-run summary -p "<task>" --file "src/**" --file "!**/*.test.*"
npx -y @steipete/oracle --dry-run full -p "<task>" --file "src/**"
```

Token/cost check:
```bash
npx -y @steipete/oracle --dry-run summary --files-report -p "<task>" --file "src/**"
```

Browser run:
```bash
npx -y @steipete/oracle --engine browser --model gpt-5.2-pro -p "<task>" --file "src/**"
```

Manual paste fallback:
```bash
npx -y @steipete/oracle --render --copy -p "<task>" --file "src/**"
```

## Attaching Files (`--file`)

`--file` accepts files, directories, and globs. Pass multiple times or comma-separate.

Include:
```bash
--file "src/**"              # directory glob
--file src/index.ts          # literal file
--file docs --file README.md # directory + file
```

Exclude (prefix with `!`):
```bash
--file "src/**" --file "!src/**/*.test.ts" --file "!**/*.snap"
```

Defaults:
- Ignored dirs: `node_modules`, `dist`, `coverage`, `.git`, `.turbo`, `.next`, `build`, `tmp`
- Honors `.gitignore`
- No symlinks followed
- Dotfiles filtered unless explicit pattern (e.g. `--file ".github/**"`)
- Hard cap: files > 1 MB rejected

## Budget + Observability

- Target: keep total input under ~196k tokens
- Use `--files-report` to spot token hogs
- Advanced: `npx -y @steipete/oracle --help --verbose`

## Engines (API vs Browser)

- Auto-pick: uses `api` when `OPENAI_API_KEY` set, otherwise `browser`
- Browser supports GPT + Gemini only
- Use `--engine api` for Claude/Grok/Codex or multi-model runs
- **API runs require explicit user consent** (usage costs)

Browser attachments:
```bash
--browser-attachments auto|never|always
```
Auto pastes inline up to ~60k chars, then uploads.

Remote browser host:
```bash
# Host
oracle serve --host 0.0.0.0 --port 9473 --token <secret>

# Client
oracle --engine browser --remote-host <host:port> --remote-token <secret> -p "<task>" --file "src/**"
```

## Sessions + Slugs

- Stored: `~/.oracle/sessions` (override: `ORACLE_HOME_DIR`)
- Long runs may detach. Don't re-run; reattach:
  ```bash
  oracle status --hours 72
  oracle session <id> --render
  ```
- Use `--slug "<3-5 words>"` for readable IDs
- Duplicate prompt guard; use `--force` for fresh run

## Prompt Template

Oracle starts with **zero** project knowledge. Include:
- Project briefing (stack + build/test commands + platform)
- Key directories, entrypoints, config files
- Exact question + what you tried + error text
- Constraints ("don't change X", "keep public API")
- Desired output ("patch plan + tests", "3 options with tradeoffs")

### Exhaustive Prompt Pattern

For long investigations:
- Top: 6-30 sentence project briefing + goal
- Middle: repro steps + exact errors + what you tried
- Bottom: all context files needed for fresh model

## Safety

- Don't attach secrets (`.env`, key files, tokens)
- Redact aggressively
- "Just enough context": fewer files + better prompt beats whole-repo dumps

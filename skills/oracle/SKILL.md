---
name: oracle
description: Use the @steipete/oracle CLI to bundle a prompt plus the right files and get a second-model review (API or browser) for debugging, refactors, design checks, or cross-validation.
---

# Oracle CLI

Bundle prompt + files into a one-shot request to another model (GPT-5.2 Pro, Claude, Gemini) for review. Treat outputs as advisory.

## Quick Start

```bash
# Preview (no tokens)
npx -y @steipete/oracle --dry-run summary -p "<task>" --file "src/**"

# Browser run (main path)
npx -y @steipete/oracle --engine browser --model gpt-5.2-pro -p "<task>" --file "src/**"

# Copy to clipboard for manual paste
npx -y @steipete/oracle --render --copy -p "<task>" --file "src/**"
```

## Golden Path

1. Pick tight file set (fewest files with the truth)
2. Preview first (`--dry-run` + `--files-report`)
3. Run browser mode for GPT-5.2 Pro; API for Claude/Grok
4. If timeout: reattach to session, don't re-run

## File Selection

```bash
--file "src/**"                    # Include glob
--file "!src/**/*.test.ts"         # Exclude pattern
--file src/index.ts --file docs/   # Multiple files/dirs
```

Default ignores: `node_modules`, `dist`, `.git`, `build`, etc.

For detailed usage, engines, sessions, and prompt templates, see [reference.md](reference.md).

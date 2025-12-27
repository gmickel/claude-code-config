---
name: sheets-cli
description: Read, write, and update Google Sheets data via CLI. Use when the user asks to read spreadsheet data, update cells, append rows, or work with Google Sheets. Triggers on mentions of spreadsheets, sheets, Google Sheets, tabular data in the cloud, or specific sheet names like "Projects" or "Tasks".
---

# sheets-cli

CLI for Google Sheets. Read tables, append rows, update cells by key or index, batch operations.

> **Installation:** Already installed in PATH. Run commands directly.

## Quick Start

```bash
sheets-cli sheets find --name "Projects"                    # Find spreadsheet
sheets-cli read table --spreadsheet <id> --sheet "Sheet1"   # Read data
sheets-cli update key --spreadsheet <id> --sheet "Tasks" \
  --key-col "ID" --key "TASK-42" --set '{"Status":"Done"}'  # Update by key
```

## Workflow

Always: **read → decide → dry-run → apply**

```bash
sheets-cli read table --sheet "Tasks" --limit 100
sheets-cli update key ... --dry-run   # Preview first
sheets-cli update key ...             # Then apply
```

For complete command reference, see [reference.md](reference.md).

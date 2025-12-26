#!/bin/bash
# Non-destructive install of Claude Code config to ~/.claude/
# Never overwrites existing files

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/.claude"

echo "Installing to ${TARGET_DIR}..."

# Create target dirs if needed
mkdir -p "${TARGET_DIR}/skills" "${TARGET_DIR}/commands" "${TARGET_DIR}/agents"

copied=0
skipped=0

copy_if_missing() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "  SKIP (exists): ${dest#$TARGET_DIR/}"
    skipped=$((skipped + 1))
  else
    mkdir -p "$(dirname "$dest")"
    cp -R "$src" "$dest"
    echo "  COPY: ${dest#$TARGET_DIR/}"
    copied=$((copied + 1))
  fi
}

# Copy skills (each skill is a directory)
for skill in "${SCRIPT_DIR}"/skills/*/; do
  [[ -d "$skill" ]] || continue
  name=$(basename "$skill")
  copy_if_missing "$skill" "${TARGET_DIR}/skills/${name}"
done

# Copy commands (each command is a file)
for cmd in "${SCRIPT_DIR}"/commands/*.md; do
  [[ -f "$cmd" ]] || continue
  name=$(basename "$cmd")
  copy_if_missing "$cmd" "${TARGET_DIR}/commands/${name}"
done

# Copy agents (each agent is a file)
for agent in "${SCRIPT_DIR}"/agents/*.md; do
  [[ -f "$agent" ]] || continue
  name=$(basename "$agent")
  copy_if_missing "$agent" "${TARGET_DIR}/agents/${name}"
done

echo ""
echo "Done: ${copied} copied, ${skipped} skipped (already exist)"

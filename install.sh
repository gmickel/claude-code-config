#!/bin/bash
# Non-destructive install of Claude Code config to ~/.claude/
# Never overwrites existing files
# Usage: ./install.sh [--skills] [--commands] [--legacy] [--all]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/.claude"

# Parse args
INSTALL_SKILLS=false
INSTALL_COMMANDS=false
INSTALL_LEGACY=false

if [[ $# -eq 0 ]]; then
  INSTALL_SKILLS=true
  INSTALL_COMMANDS=true
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skills)   INSTALL_SKILLS=true ;;
      --commands) INSTALL_COMMANDS=true ;;
      --legacy)   INSTALL_LEGACY=true ;;
      --all)
        INSTALL_SKILLS=true
        INSTALL_COMMANDS=true
        INSTALL_LEGACY=true
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: ./install.sh [--skills] [--commands] [--legacy] [--all]"
        exit 1
        ;;
    esac
    shift
  done
fi

echo "Installing to ${TARGET_DIR}..."

# Create target dirs if needed
mkdir -p "${TARGET_DIR}/skills" "${TARGET_DIR}/commands"

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

# Skills
if [[ "$INSTALL_SKILLS" == "true" ]]; then
  echo "Skills:"
  for skill in "${SCRIPT_DIR}"/skills/*/; do
    [[ -d "$skill" ]] || continue
    name=$(basename "$skill")
    copy_if_missing "$skill" "${TARGET_DIR}/skills/${name}"
  done
fi

# Commands
if [[ "$INSTALL_COMMANDS" == "true" ]]; then
  echo "Commands:"
  for cmd in "${SCRIPT_DIR}"/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    name=$(basename "$cmd")
    copy_if_missing "$cmd" "${TARGET_DIR}/commands/${name}"
  done
fi

# Legacy (commands + agents from legacy/)
if [[ "$INSTALL_LEGACY" == "true" ]]; then
  echo "Legacy commands:"
  mkdir -p "${TARGET_DIR}/commands"
  for cmd in "${SCRIPT_DIR}"/legacy/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    name=$(basename "$cmd")
    copy_if_missing "$cmd" "${TARGET_DIR}/commands/${name}"
  done

  echo "Legacy agents:"
  mkdir -p "${TARGET_DIR}/agents"
  for agent in "${SCRIPT_DIR}"/legacy/agents/*.md; do
    [[ -f "$agent" ]] || continue
    name=$(basename "$agent")
    copy_if_missing "$agent" "${TARGET_DIR}/agents/${name}"
  done
fi

echo ""
echo "Done: ${copied} copied, ${skipped} skipped (already exist)"

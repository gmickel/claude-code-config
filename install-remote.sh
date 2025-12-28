#!/bin/bash
# Remote installer for Claude Code config
# Usage: curl -fsSL https://raw.githubusercontent.com/gmickel/claude-code-config/main/install-remote.sh | bash
# Options: curl ... | bash -s -- [--skills] [--commands] [--legacy] [--all]
#
# Requires: curl, jq
# Optional: GITHUB_TOKEN env var for higher rate limits

set -euo pipefail

REPO="gmickel/claude-code-config"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API_BASE="https://api.github.com/repos/${REPO}/contents"
TARGET_DIR="${HOME}/.claude"

# Check for jq
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  echo "Install via: brew install jq (macOS) or apt install jq (Linux)"
  exit 1
fi

# GitHub API auth header (optional, for rate limits)
AUTH_HEADER=""
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
elif [[ -n "${GH_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: token ${GH_TOKEN}"
fi

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
        echo "Usage: curl ... | bash -s -- [--skills] [--commands] [--legacy] [--all]"
        exit 1
        ;;
    esac
    shift
  done
fi

echo "Installing Claude Code config to ${TARGET_DIR}..."
echo ""

# Counters (global, updated via process substitution to avoid subshell issues)
copied=0
skipped=0
failed=0

# Validate path segment (prevent path traversal)
validate_name() {
  local name="$1"
  if [[ -z "$name" ]] || [[ "$name" == "." ]] || [[ "$name" == ".." ]] || [[ "$name" == *"/"* ]] || [[ "$name" == *"\\"* ]]; then
    echo "Error: Invalid path segment: ${name}" >&2
    return 1
  fi
  return 0
}

# Fetch directory listing from GitHub API
fetch_api() {
  local path="$1"
  local url="${API_BASE}/${path}?ref=${BRANCH}"
  local response

  if [[ -n "$AUTH_HEADER" ]]; then
    response=$(curl -fsSL --proto '=https' --tlsv1.2 -H "$AUTH_HEADER" "$url" 2>&1) || {
      echo "Error: Failed to fetch ${path} from GitHub API" >&2
      echo "Response: ${response}" >&2
      return 1
    }
  else
    response=$(curl -fsSL --proto '=https' --tlsv1.2 "$url" 2>&1) || {
      echo "Error: Failed to fetch ${path} from GitHub API" >&2
      echo "Response: ${response}" >&2
      return 1
    }
  fi

  # Check for rate limit or error response
  if echo "$response" | jq -e '.message' &>/dev/null; then
    local msg
    msg=$(echo "$response" | jq -r '.message')
    if [[ "$msg" == *"rate limit"* ]]; then
      echo "Error: GitHub API rate limit exceeded." >&2
      echo "Set GITHUB_TOKEN or GH_TOKEN env var to increase limit." >&2
      return 1
    elif [[ "$msg" != "null" ]]; then
      echo "Error: GitHub API error: ${msg}" >&2
      return 1
    fi
  fi

  echo "$response"
}

download_file() {
  local url="$1"
  local dest="$2"
  local dest_dir
  local tmp_file

  dest_dir=$(dirname "$dest")
  mkdir -p "$dest_dir"

  # Create temp file in same directory for atomic move
  tmp_file="${dest_dir}/.tmp.$(basename "$dest").$$"

  if curl -fsSL --proto '=https' --tlsv1.2 "$url" -o "$tmp_file" 2>/dev/null; then
    # Check again before move (TOCTOU mitigation)
    if [[ -e "$dest" || -L "$dest" ]]; then
      rm -f "$tmp_file"
      return 2  # Signal "already exists"
    fi
    mv "$tmp_file" "$dest"
    return 0
  else
    rm -f "$tmp_file"
    return 1
  fi
}

download_if_missing() {
  local url="$1"
  local dest="$2"
  local rel="${dest#"$TARGET_DIR"/}"
  local result

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "  SKIP (exists): ${rel}"
    skipped=$((skipped + 1))
    return
  fi

  result=0
  download_file "$url" "$dest" || result=$?

  if [[ $result -eq 0 ]]; then
    echo "  COPY: ${rel}"
    copied=$((copied + 1))
  elif [[ $result -eq 2 ]]; then
    echo "  SKIP (exists): ${rel}"
    skipped=$((skipped + 1))
  else
    echo "  FAIL: ${rel}"
    failed=$((failed + 1))
  fi
}

# Install a skill directory recursively
install_skill() {
  local skill_name="$1"

  validate_name "$skill_name" || return

  local skill_path="skills/${skill_name}"
  local skill_dir="${TARGET_DIR}/skills/${skill_name}"

  if [[ -e "$skill_dir" || -L "$skill_dir" ]]; then
    echo "  SKIP (exists): skills/${skill_name}/"
    skipped=$((skipped + 1))
    return
  fi

  mkdir -p "$skill_dir"

  local listing
  listing=$(fetch_api "$skill_path") || {
    failed=$((failed + 1))
    return
  }

  # Get file list (avoid subshell by using process substitution)
  local files
  mapfile -t files < <(echo "$listing" | jq -r '.[] | select(.type=="file") | .name')

  for file in "${files[@]}"; do
    [[ -z "$file" ]] && continue
    validate_name "$file" || continue
    download_if_missing "${RAW_BASE}/${skill_path}/${file}" "${skill_dir}/${file}"
  done

  # Get subdirectory list
  local subdirs
  mapfile -t subdirs < <(echo "$listing" | jq -r '.[] | select(.type=="dir") | .name')

  for subdir in "${subdirs[@]}"; do
    [[ -z "$subdir" ]] && continue
    validate_name "$subdir" || continue
    mkdir -p "${skill_dir}/${subdir}"

    local sub_listing
    sub_listing=$(fetch_api "${skill_path}/${subdir}") || continue

    local subfiles
    mapfile -t subfiles < <(echo "$sub_listing" | jq -r '.[] | select(.type=="file") | .name')

    for subfile in "${subfiles[@]}"; do
      [[ -z "$subfile" ]] && continue
      validate_name "$subfile" || continue
      download_if_missing "${RAW_BASE}/${skill_path}/${subdir}/${subfile}" "${skill_dir}/${subdir}/${subfile}"
    done
  done
}

# Skills
if [[ "$INSTALL_SKILLS" == "true" ]]; then
  echo "Skills:"
  mkdir -p "${TARGET_DIR}/skills"

  skills_listing=$(fetch_api "skills") || exit 1

  mapfile -t skills < <(echo "$skills_listing" | jq -r '.[] | select(.type=="dir") | .name')

  for skill in "${skills[@]}"; do
    [[ -z "$skill" ]] && continue
    [[ "$skill" == .* ]] && continue  # Skip hidden dirs
    install_skill "$skill"
  done
  echo ""
fi

# Commands
if [[ "$INSTALL_COMMANDS" == "true" ]]; then
  echo "Commands:"
  mkdir -p "${TARGET_DIR}/commands"

  commands_listing=$(fetch_api "commands") || exit 1

  mapfile -t commands < <(echo "$commands_listing" | jq -r '.[] | select(.type=="file") | select(.name | endswith(".md")) | .name')

  for cmd in "${commands[@]}"; do
    [[ -z "$cmd" ]] && continue
    validate_name "$cmd" || continue
    download_if_missing "${RAW_BASE}/commands/${cmd}" "${TARGET_DIR}/commands/${cmd}"
  done
  echo ""
fi

# Legacy (commands + agents from legacy/)
if [[ "$INSTALL_LEGACY" == "true" ]]; then
  echo "Legacy commands:"
  mkdir -p "${TARGET_DIR}/commands"

  legacy_cmds_listing=$(fetch_api "legacy/commands") || exit 1

  mapfile -t legacy_cmds < <(echo "$legacy_cmds_listing" | jq -r '.[] | select(.type=="file") | select(.name | endswith(".md")) | .name')

  for cmd in "${legacy_cmds[@]}"; do
    [[ -z "$cmd" ]] && continue
    validate_name "$cmd" || continue
    download_if_missing "${RAW_BASE}/legacy/commands/${cmd}" "${TARGET_DIR}/commands/${cmd}"
  done
  echo ""

  echo "Legacy agents:"
  mkdir -p "${TARGET_DIR}/agents"

  legacy_agents_listing=$(fetch_api "legacy/agents") || exit 1

  mapfile -t legacy_agents < <(echo "$legacy_agents_listing" | jq -r '.[] | select(.type=="file") | select(.name | endswith(".md")) | .name')

  for agent in "${legacy_agents[@]}"; do
    [[ -z "$agent" ]] && continue
    validate_name "$agent" || continue
    download_if_missing "${RAW_BASE}/legacy/agents/${agent}" "${TARGET_DIR}/agents/${agent}"
  done
  echo ""
fi

echo "Done: ${copied} copied, ${skipped} skipped, ${failed} failed"

if [[ $failed -gt 0 ]]; then
  echo "Warning: Some files failed to download."
  exit 1
fi

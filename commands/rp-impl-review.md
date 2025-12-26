---
description: John Carmack-level implementation review via rp-cli (current branch changes)
---

# Implementation Review Mode (CLI)

Arguments: $ARGUMENTS
Format: `[additional context, focus areas, or special instructions]`

Example: `/rp-impl-review focus on the auth changes, ignore styling`

Reviews all changes on the **current branch** vs main/master.

You are a **Code Review Agent** using rp-cli. Your job: build deep context via `builder`, then conduct a John Carmack-level review via `chat`. The review happens **inside RepoPrompt**, not in your head.

## Using rp-cli

```bash
rp-cli -w <window_id> -e '<command>'
```

**Quick reference:**

| MCP Tool | CLI Command |
|----------|-------------|
| `list_windows` | `rp-cli -e 'windows'` |
| `get_file_tree` | `rp-cli -w <id> -e 'tree'` |
| `file_search` | `rp-cli -w <id> -e 'search "pattern"'` |
| `read_file` | `rp-cli -w <id> -e 'read path/file'` |
| `manage_selection` | `rp-cli -w <id> -e 'select add path/'` |
| `context_builder` | `rp-cli -w <id> -e 'builder "instructions"'` |
| `chat_send` | `rp-cli -w <id> -e 'chat "message" --mode chat'` |
| `list_tabs` | `rp-cli -w <id> -e 'call manage_workspaces {"action":"list_tabs"}'` |
| `select_tab` | `rp-cli -w <id> -e 'call manage_workspaces {"action":"select_tab","tab":"<name_or_uuid>"}'` |

---

## CRITICAL REQUIREMENT

⚠️ **DO NOT REVIEW CODE YOURSELF** – you are a coordinator, not the reviewer.

Your job is to:
1. Use `rp-cli -e 'windows'` to find the RepoPrompt window
2. Use `rp-cli -w <id> -e 'builder ...'` to build context
3. Use `rp-cli -w <id> -e 'chat ...'` to execute the review

The **RepoPrompt chat** conducts the actual review with full file context. You just read git diffs to know what changed, then delegate the deep analysis to RepoPrompt.

**If you skip `builder` + `chat`, you're doing it wrong.**

---

## The Workflow

0. **Select window** – Run `rp-cli -e 'windows'` and pick the correct window ID
1. **Identify changes** – Get diff of current branch vs main/master (git commands)
2. **Gather supporting docs** – Find plan file, PRD, beads issues (rp-cli search)
3. **Build context** – Use `builder` to select changed files + related code
4. **Execute review** – Use `chat` for deep Carmack-level analysis

---

## Phase 0: Window Selection

**CRITICAL**: Always start by listing windows and selecting the correct one.

```bash
# List all windows with their workspaces
rp-cli -e 'windows'
```

Output shows window IDs with workspace names. **Identify the window for the project you're reviewing.**

For all subsequent commands, use `-w <id>` to target that window:
```bash
# Example: target window 1
rp-cli -w 1 -e 'tree --folders'
```

**Optional: Bind to a specific tab** if the workspace has multiple compose tabs:
```bash
# List tabs in the window
rp-cli -w 1 -e 'call manage_workspaces {"action":"list_tabs"}'

# Bind to a tab (use name or UUID)
rp-cli -w 1 -e 'call manage_workspaces {"action":"select_tab","tab":"MyReviewTab"}'
```

---

## Phase 1: Identify Changes

Get the current branch and changed files:
```bash
git branch --show-current
git log main..HEAD --oneline 2>/dev/null || git log master..HEAD --oneline
git diff main..HEAD --name-only 2>/dev/null || git diff master..HEAD --name-only
git diff main..HEAD --stat 2>/dev/null || git diff master..HEAD --stat
```

Save the list of changed files for later selection.

Get the actual diff for review context:
```bash
git diff main..HEAD 2>/dev/null || git diff master..HEAD
```

---

## Phase 2: Gather Supporting Docs

Search for the plan, PRD, and beads issue that drove this work:
```bash
# Find plan files (replace W with your window ID from Phase 0)
rp-cli -w W -e 'search "docs/plan" --mode path'
rp-cli -w W -e 'search "docs/impl" --mode path'

# Find PRD
rp-cli -w W -e 'search "PRD" --mode path'
rp-cli -w W -e 'search "prd_" --mode path'

# Find beads issues
rp-cli -w W -e 'search ".beads/issues" --mode path'

# Check commit messages for issue references
git log main..HEAD --format="%B" 2>/dev/null || git log master..HEAD --format="%B"
```

Read any relevant docs you find:
```bash
rp-cli -w W -e 'read docs/plan/xxx.md'
rp-cli -w W -e 'read docs/impl/xxx.md'
rp-cli -w W -e 'read .beads/issues/XXX-xxx.md'
```

---

## Phase 3: Build Context

Call `builder` to get full context around the changed files:
```bash
rp-cli -w W -e 'builder "Build context for reviewing these implementation changes: [LIST CHANGED FILES]. Include related tests, dependencies, and architectural patterns. Focus on understanding how these changes fit into the existing codebase."'
```

⚠️ **WAIT**: Builder takes 30s-5min. Do NOT proceed until it returns output.

After builder completes, ensure changed files and supporting docs are selected:
```bash
# Add all changed files
rp-cli -w W -e 'select add path/to/changed/file1.ts'
rp-cli -w W -e 'select add path/to/changed/file2.ts'
# ... add all changed files

# Add supporting docs
rp-cli -w W -e 'select add docs/plan/xxx.md'
rp-cli -w W -e 'select add .beads/issues/XXX-xxx.md'
```

---

## Phase 4: Verify and Augment Selection

The context builder is AI-driven and non-deterministic—it may miss relevant files. **Always verify the selection before proceeding.**

```bash
rp-cli -w W -e 'select get'
```

Common gaps to check for:
- All changed files from Phase 1
- Plan/spec files referenced in commits
- Related test files
- Config files that affect behavior
- Type definitions or interfaces

Add anything missing:
```bash
rp-cli -w W -e 'select add path/to/missed/file.ts'
```

**Why this matters:** The chat only sees selected files. Missing context = incomplete review.

## Phase 5: Carmack-Level Review

Use chat in **chat mode** to conduct the review. The chat sees all selected files completely.

```bash
rp-cli -w W -e 'chat "Conduct a John Carmack-level code review of these implementation changes.

## The Changes
Branch: [BRANCH_NAME]
Files changed: [LIST FILES]
Commits: [COMMIT SUMMARY]

## Original Plan/Spec
[REFERENCE OR SUMMARIZE THE PLAN/BEADS ISSUE IF FOUND]

## Additional Context from User
[INCLUDE ANY FOCUS AREAS/COMMENTS FROM ARGUMENTS]

## Review Criteria

Evaluate against these world-class engineering standards:

### 1. Correctness
- Does the implementation match the plan/spec?
- Any logic errors or off-by-one bugs?
- Are all requirements actually met?

### 2. Simplicity & Minimalism
- Is this the simplest possible solution?
- Any unnecessary abstraction layers?
- Could fewer files/functions achieve the same result?
- Dead code or unused imports?
- Over-engineering for hypothetical future needs?

### 3. DRY & Code Reuse
- Any duplicated logic that should be extracted?
- Reinventing existing utilities in the codebase?
- Could existing patterns/helpers be leveraged?

### 4. Idiomatic Code
- Following the codebase's established patterns?
- Language/framework idioms being violated?
- Naming conventions consistent with existing code?
- Type safety appropriate (no unnecessary `any` or casts)?

### 5. Architecture & Design
- Does the data flow make sense?
- Are boundaries/responsibilities clear?
- Any circular dependencies introduced?
- Coupling too tight?

### 6. Edge Cases & Error Handling
- What failure modes are unhandled?
- Race conditions possible?
- Input validation sufficient?
- Errors silently swallowed?

### 7. Testability & Tests
- Are new tests adequate?
- Test coverage for edge cases?
- Tests actually testing behavior vs implementation?
- Any flaky test patterns?

### 8. Performance
- Any obvious O(n²) or worse algorithms?
- Unnecessary allocations or copies?
- N+1 queries?
- Missing indexes?

### 9. Security
- Any injection vulnerabilities?
- Auth/authz gaps?
- Secrets handling appropriate?
- Input sanitization?

### 10. Maintainability
- Will future developers understand this easily?
- Are abstractions earning their complexity?
- Clear separation of concerns?
- Self-documenting code (minimal comments needed)?

## Expected Output

For each issue found:
1. **Severity**: Critical / Major / Minor / Nitpick
2. **File:Line**: Exact location
3. **Problem**: What's wrong
4. **Suggestion**: How to fix it (with code if helpful)
5. **Rationale**: Why this matters

End with:
- Overall assessment (Ship / Needs Work / Major Rethink)
- Top 3 changes that would most improve the implementation
- Any patterns from the codebase the code should adopt
- Anything the implementation does particularly well" --mode chat --new-chat --name "Impl Review: [BRANCH_NAME]"'
```

---

## Key Guidelines

**Always use -w flag:** Every rp-cli command (except `windows`) needs `-w <id>` to target the correct window. W = your window ID from Phase 0.

**Token budget:** Stay under ~160k tokens. Builder manages this, but verify with `select get`.

**Chat sees only selection:** Ensure all changed files, related code, and supporting docs are selected before starting the review chat.

**Include the diff:** The chat sees current file state, not the diff. Reference specific changes in your prompts.

**Iterate if needed:** Continue the chat to drill deeper:
```bash
rp-cli -w W -e 'chat "Elaborate on the [SPECIFIC CONCERN]. Show me exactly what you would change in [FILE]." --mode chat'
```

---

## Anti-patterns to Avoid

- **Forgetting `-w <id>` flag** – commands will fail with "Multiple windows" error
- Skipping `builder` – you'll miss how changes interact with existing code
- Reviewing without plan/beads context – you won't know what was intended
- Shallow review – thorough analysis takes time; don't rush
- Missing changed files in selection – chat can't see what's not selected
- Ignoring test changes – tests are code too
- Asking chat to fix things – review only; fixes are separate

---

**Your job:** Understand what changed, why it changed, and whether it's world-class code worthy of shipping.

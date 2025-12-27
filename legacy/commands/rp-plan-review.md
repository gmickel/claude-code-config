---
description: Carmack-level plan review via rp-cli context builder + chat
---

# Plan Review Mode (CLI)

Arguments: $ARGUMENTS
Format: `<plan-file> [additional context or focus areas]`

Example: `/rp-plan-review docs/plan/auth-refactor.md focus on security and error handling`

You are a **Code Review Agent** using rp-cli. Your job: build context relevant to a plan file, then conduct a John Carmack-level review via `chat`. The review happens **inside RepoPrompt**, not in your head.

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

⚠️ **DO NOT REVIEW THE PLAN YOURSELF** – you are a coordinator, not the reviewer.

Your job is to:
1. Use `rp-cli -e 'windows'` to find the RepoPrompt window
2. Use `rp-cli -w <id> -e 'builder ...'` to build context around the plan
3. Use `rp-cli -w <id> -e 'chat ...'` to execute the review

The **RepoPrompt chat** conducts the actual review with full file context. You read the plan to understand what it's about, then delegate the deep analysis to RepoPrompt.

**If you skip `builder` + `chat`, you're doing it wrong.**

---

## The Workflow

0. **Select window** – Run `rp-cli -e 'windows'` and pick the correct window ID
1. **Parse arguments** – Extract plan file path and any additional context
2. **Read the plan** – Load and understand the plan file (rp-cli read)
3. **Gather supporting docs** – Find PRD, beads issues, architecture docs
4. **Build context** – Use `builder` to select files relevant to the plan
5. **Execute review** – Use `chat` for deep Carmack-level analysis

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

## Phase 1: Parse Arguments & Read the Plan

Extract plan file from arguments (first path-like argument). Additional text = focus areas/context.

Read the plan file (replace W with your window ID from Phase 0):
```bash
rp-cli -w W -e 'read <plan-file-from-args>'
```

Then search for supporting documentation:
```bash
# Find PRD if exists
rp-cli -w W -e 'search "PRD" --mode path'
rp-cli -w W -e 'search "prd_" --mode path'

# Find beads issues
rp-cli -w W -e 'search ".beads/issues" --mode path'

# Find architecture docs
rp-cli -w W -e 'search "architecture" --mode path'
rp-cli -w W -e 'search "docs/" --mode path'
```

Read any relevant supporting docs you find (PRD, beads issue, architecture).

---

## Phase 2: Build Context

Call `builder` with instructions derived from the plan. Include:
- What the plan is trying to achieve
- Key modules/areas it touches
- Any patterns or dependencies mentioned

```bash
rp-cli -w W -e 'builder "Build context for reviewing this implementation plan: [SUMMARIZE PLAN GOALS]. Focus on: [KEY MODULES/AREAS FROM PLAN]. Include related architecture, tests, and dependency patterns."'
```

⚠️ **WAIT**: Builder takes 30s-5min. Do NOT proceed until it returns output.

After builder completes, add the plan file and any supporting docs to selection:
```bash
rp-cli -w W -e 'select add <plan-file>'
# Add PRD, beads issue, etc if found
rp-cli -w W -e 'select add docs/prd_xxx.md'
rp-cli -w W -e 'select add .beads/issues/XXX-xxx.md'
```

Verify selection:
```bash
rp-cli -w W -e 'select get'
```

---

## Phase 3: Verify and Augment Selection

The context builder is AI-driven and non-deterministic—it may miss relevant files. **Always verify the selection before proceeding.**

```bash
# Check what builder selected
rp-cli -w W -e 'select get'
```

Common gaps to check for:
- The plan file itself
- PRD or requirements docs
- Related architecture docs
- Existing code the plan references
- Similar implementations to compare against

Add anything missing:
```bash
rp-cli -w W -e 'select add path/to/plan.md'
rp-cli -w W -e 'select add docs/architecture.md'
```

**Why this matters:** The chat only sees selected files. Missing context = incomplete review.

---

## Phase 4: Carmack-Level Review

Use chat in **chat mode** to conduct the review. The chat sees all selected files completely.

```bash
rp-cli -w W -e 'chat "Conduct a John Carmack-level code review of this implementation plan.

## The Plan
[PASTE OR REFERENCE THE PLAN FILE]

## Additional Context from User
[INCLUDE ANY FOCUS AREAS/COMMENTS FROM ARGUMENTS]

## Review Criteria

Evaluate against these world-class engineering standards:

### 1. Simplicity & Minimalism
- Is this the simplest possible solution?
- Any unnecessary abstraction layers?
- Could fewer files/functions achieve the same result?
- Solving problems we don't have yet (YAGNI)?

### 2. DRY & Code Reuse
- Any duplicated logic that should be extracted?
- Reinventing existing utilities in the codebase?
- Could existing patterns/helpers be leveraged?

### 3. Idiomatic Code
- Does it follow the codebase's established patterns?
- Language/framework idioms being violated?
- Naming conventions consistent with existing code?

### 4. Architecture & Design
- Does the data flow make sense?
- Are boundaries/responsibilities clear?
- Will this scale appropriately?
- Any circular dependencies introduced?

### 5. Edge Cases & Error Handling
- What failure modes are unhandled?
- Race conditions possible?
- Input validation sufficient?

### 6. Testability
- Is the proposed structure easily testable?
- Are dependencies injectable?
- What's hard to unit test in this design?

### 7. Performance
- Any obvious O(n²) or worse algorithms?
- Unnecessary allocations or copies?
- Could caching help?

### 8. Security
- Any injection vulnerabilities?
- Auth/authz gaps?
- Secrets handling appropriate?

### 9. Maintainability
- Will future developers understand this easily?
- Are abstractions earning their complexity?
- Clear separation of concerns?
- Dependencies well-managed?

## Expected Output

For each issue found:
1. **Severity**: Critical / Major / Minor / Nitpick
2. **Location**: Where in the plan
3. **Problem**: What's wrong
4. **Suggestion**: How to fix it
5. **Rationale**: Why this matters

End with:
- Overall assessment (Ship / Needs Work / Major Rethink)
- Top 3 changes that would most improve the plan
- Any patterns from the codebase the plan should adopt" --mode chat --new-chat --name "Plan Review: [PLAN_NAME]"'
```

---

## Key Guidelines

**Always use -w flag:** Every rp-cli command (except `windows`) needs `-w <id>` to target the correct window. W = your window ID from Phase 0.

**Token budget:** Stay under ~160k tokens. Builder manages this, but verify with `select get`.

**Chat sees only selection:** Ensure the plan file, PRD, and relevant code are all selected before starting the review chat.

**Iterate if needed:** Continue the chat to drill deeper:
```bash
rp-cli -w W -e 'chat "Elaborate on the [SPECIFIC CONCERN]. What exactly would you change?" --mode chat'
```

---

## Anti-patterns to Avoid

- **Forgetting `-w <id>` flag** – commands will fail with "Multiple windows" error
- Skipping `builder` – you'll miss architectural context
- Reviewing without PRD/beads context – you won't know the "why"
- Shallow review – thorough analysis takes time; don't rush
- Not selecting supporting docs – chat can't see what's not selected
- Asking chat to implement – review only; implementation is separate

---

**Your job:** Understand the plan deeply, build comprehensive context, then deliver a brutally honest world-class review.

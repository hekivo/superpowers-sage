# Hooks

Hooks are shell scripts that run automatically at lifecycle events — they consume **zero LLM tokens** and require no prompt from you.

---

## SessionStart

**Script:** `hooks/session-start.sh`  
**Trigger:** Beginning of every session in a Sage project.

**What it injects:**

A compact routing table (~1,284 chars) that includes:
- The Lando runner rule (`all wp/composer/php/node/npm commands via lando <cmd>`)
- A quick cache/build reference (`lando flush` for PHP, `lando theme-build` for assets)
- A 15-row decision table mapping common tasks to skills

This replaced the previous behavior of injecting the full `sageing` SKILL.md (18,622 chars, 270 lines) on every session. See [token-efficiency.md](token-efficiency.md) for details.

**Side effects (zero-token, before injection):**
- Detects whether the current directory contains a Sage/Acorn project (exits silently if not)
- Detects configured design tools (Paper, Figma, Stitch, Playwright)
- Detects Lando availability and Livewire installation
- Includes the active plan path if one is `status: in-progress`

---

## UserPromptSubmit — Keyword Router

**Script:** `hooks/user-prompt-activate.sh`  
**Trigger:** Every user message.

**Logic:**
1. Lowercases the prompt
2. Scans against 32 keyword entries (each entry has `|`-separated aliases mapping to a skill name)
3. If **exactly 1** skill matches → injects an `additionalContext` hint pointing to that skill
4. If **0 or 2+** skills match → exits silently (avoids injecting the wrong skill when intent is ambiguous)

**Complete keyword map:**

| Skill | Triggers |
|---|---|
| `onboarding` | `/onboarding`, `project orientation`, `what exists in this project`, `first session`, `onboard to this` |
| `reviewing` | `/reviewing`, `sage-reviewer`, `run a review`, `review my block`, `pre-pr review`, `review before pr`, `convention audit` |
| `debugging` | `/debugging`, `lando logs show`, `acorn boot error`, `blade rendering error`, `livewire mount fail`, `debug this issue`, `something is broken` |
| `building` | `/building`, `implement from the plan`, `build from the plan`, `execute the plan`, `building skill`, `start building` |
| `architecture-discovery` | `/architecture-discovery`, `map the codebase`, `discover the architecture`, `architecture discovery` |
| `plan-generator` | `/plan-generator`, `generate the plan`, `write the plan`, `plan-generator skill` |
| `designing` | `/designing`, `extract from figma`, `extract from pencil`, `design to blade`, `paper.design url`, `pencil design` |
| `verifying` | `/verifying`, `visual verification`, `compare to design`, `screenshot diff`, `design drift` |
| `migrating` | `/migrating`, `post_content migration`, `acf field migration`, `data migration script` |
| `sage-design-system` | `/sage-design-system`, `design system tokens`, `kitchensink page`, `design system setup` |
| `block-scaffolding` | `/block-scaffolding`, `scaffold a block`, `new acf block`, `block-scaffolding skill` |
| `block-refactoring` | `/block-refactoring`, `refactor this block`, `block evolution`, `v1 to v2 migration`, `block refactor skill` |
| `sageing` | `/sageing`, `which skill should i use`, `skill routing`, `sage ecosystem`, `full architectural preferences` |
| `ai-setup` | `/ai-setup`, `acorn ai`, `mcp adapter`, `discover-abilities`, `install mcp` |
| `abilities-authoring` | `/abilities-authoring`, `make:ability`, `execute-ability`, `acorn ability`, `mcp endpoint`, `wp ability` |
| `acorn-livewire` | `livewire component`, `wire:model`, `wire:click`, `make:livewire`, `livewire v3` |
| `acorn-eloquent` | `eloquent model`, `model class`, `eloquent query`, `hasmany`, `belongsto`, `eloquent relationship` |
| `wp-block-native` | `block.json`, `register_block_type`, `native block`, `wp:core`, `innerblocks` |
| `sage-lando` | `lando start`, `lando stop`, `lando restart`, `lando ssh`, `lando info` |
| `acorn-queues` | `dispatch job`, `action scheduler`, `queue:work`, `queue job`, `horizon` |
| `acorn-middleware` | `http middleware`, `acorn middleware`, `terminate()` |
| `acorn-redis` | `redis cache`, `cache tags`, `cache driver`, `redis facade` |
| `acorn-logging` | `log channel`, `monolog`, `logging config`, `log::error`, `daily channel` |
| `acorn-routes` | `acorn route`, `routes/web.php`, `register route` |
| `wp-phpstan` | `phpcs`, `php codesniffer`, `phpstan`, `psalm`, `static analysis` |
| `wp-rest-api` | `wp_rest_controller`, `rest endpoint`, `register_rest_route` |
| `wp-capabilities` | `user capabilities`, `current_user_can`, `add_role`, `register_capability`, `wp roles` |
| `wp-security` | `sql injection`, `xss attack`, `nonce verification`, `sanitize_text_field`, `wp_kses`, `esc_html security` |
| `wp-performance` | `transient cache`, `object cache`, `n+1 query`, `slow wp query`, `cache invalidation` |
| `wp-hooks-lifecycle` | `add_action`, `add_filter`, `hook priority`, `plugins_loaded`, `wptexturize`, `save_post hook` |
| `wp-cli-ops` | `wp eval`, `wp post list`, `wp option update`, `wp db query` |
| `sage-forms` | `sage-html-forms`, `hf_get_form`, `html forms plugin`, `log1x/sage-html-forms` |

---

## Other Hooks

| Hook | Trigger | What it does |
|---|---|---|
| `post-edit` | After any file Write or Edit | `lando flush` for PHP files, `lando theme-build` for CSS/JS assets — zero-token cache invalidation |
| `post-compact` | Context window compression | Re-injects the active plan path and asset count so work can continue after compaction |
| `pre-commit` | Before `git commit` | Reminds to verify implementation visually against the design reference before committing |
| `post-subagent` | Subagent completes | Logs activity to the active plan's `logs/` directory |
| `post-stop` | Session ends | Logs session end to the active plan's `logs/` directory |

---

## Hook Sync Requirement

`hooks/hooks.json` (Claude Code / VS Code / Codex) and `hooks/cursor-hooks.json` (Cursor) must stay in sync. After modifying any hook entry:

```bash
node scripts/sync-cursor-hooks.mjs
```

CI enforces this — a diff between the two files fails the `manifest-sync` job.

---

## Diagnostics

### Quick check

```bash
bash scripts/doctor-hooks.sh
```

Verifies: Lando availability, Node, hook scripts executable, active plans, recent log entries.

### Debug logging

```bash
export SUPERPOWERS_SAGE_HOOK_DEBUG=1
export SUPERPOWERS_SAGE_HOOK_LOG=.superpowers-sage/hooks.log
```

Reproduce the action (edit a file, `git commit`, etc.), then:

```bash
tail -20 .superpowers-sage/hooks.log
```

Look for `HOOK_STATUS=skip` or `HOOK_STATUS=warn`.

### Common warnings

| Warning | Cause | Fix |
|---|---|---|
| `skip: lando CLI not found in PATH` | Lando not installed or not in PATH | Install Lando: `brew install lando` or [platform-specific](https://lando.dev) |
| `skip: .lando.yml not found` | Project is not Lando-based | `post-edit` only runs in Lando projects |
| `skip: file_path not found in payload` | Hook couldn't extract file path from event | Normal for non-file actions |
| `skip: no active plan found` | No plan with `status: in-progress` | Run `/architecture-discovery` → `/plan-generator`, or `/building` with an existing plan |
| `HOOK_STATUS=warn: theme-build failed` | Asset build error (Vite, Tailwind) | Run `lando theme-build` manually to see full error |

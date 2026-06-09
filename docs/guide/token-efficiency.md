# Token Efficiency

The plugin is designed to be productive without burning tokens on every session. This page explains how that works, and what contributors need to know to keep it that way.

---

## The Problem Before (pre-2026-05-28)

Every session start (`SessionStart` hook) read and injected the entire `skills/sageing/SKILL.md` file:

- **Size:** 18,622 characters, 270 lines
- **Tags:** Wrapped in `<EXTREMELY_IMPORTANT>` — guaranteed to land in the active context
- **Trigger:** Every session in every Sage project, regardless of what the user asked

Additionally, the `sageing` skill's description said *"read this first in any Sage/Acorn project session"*, which caused Claude to invoke it again via the Skill tool even after the hook had already injected it. Double-loading.

**Result:** ~18,622 chars consumed before the user typed a single character.

---

## The Solution (2026-05-28)

Three coordinated changes:

### 1. Compact routing table in SessionStart

`hooks/session-start.sh` now injects a 20-line compact routing table (~1,284 chars):
- Lando runner rule
- Cache/build quick reference
- 15-row task → skill decision table

**Reduction: 93%** (18,622 → 1,284 chars per session start).

### 2. Keyword router (UserPromptSubmit)

`hooks/user-prompt-activate.sh` scans each prompt against 32 keyword entries. When exactly 1 skill matches, it injects a short `additionalContext` hint — the skill loads **on demand only**, not on every session.

Skills that used to be speculatively loaded now only load when the prompt explicitly requests them or contains domain-specific terms.

### 3. Updated skill descriptions

All major skills now have `Invoke for:` and `Skip when:` lines in their description frontmatter. These give Claude enough signal to decide not to invoke a skill when the context doesn't match, counteracting the 1% threshold in the base `using-superpowers` skill.

---

## The 1% Threshold

The base `using-superpowers` skill contains:

> "If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill."

This is intentionally aggressive — it prevents skills from being silently skipped when they should apply. The downside: without `Invoke for:` / `Skip when:` guidance, Claude will invoke skills speculatively.

The `Invoke for:` / `Skip when:` pattern gives Claude enough signal to decide confidently — "this skill does not apply" — and skip it, even under the 1% rule.

---

## Contributor Guidance

When adding a new skill to the plugin:

**1. Write `Invoke for:` and `Skip when:` in the description frontmatter:**

```yaml
---
name: superpowers-sage:my-new-skill
description: >
  What the skill does — concise technical summary of its domain.
  Invoke for: the exact user phrases or situations that should trigger this skill.
  Skip when: situations where this skill does NOT apply, especially if they overlap with other skills.
user-invocable: true  # or false if reference-only
---
```

**2. If the skill is user-invocable, add it to the keyword router:**

In `hooks/user-prompt-activate.sh`, add an entry to `KEYWORD_MAP`:

```bash
"/my-new-skill|phrase that means this|another trigger phrase:my-new-skill"
```

Format: `keyword1|keyword2|...:skill-name` (skill-name matches the last segment of the `name:` frontmatter field).

**3. Run the hook sync:**

```bash
node scripts/sync-cursor-hooks.mjs
```

**4. Update `docs/guide/skills.md`** — add the skill to the workflow or reference table.

**5. Update `docs/guide/hooks.md`** — add the keyword entries to the keyword map table.

---

## Measurement

To estimate token cost of a session start, check the `COMPACT_GUIDE` variable length:

```bash
bash -c '
COMPACT_GUIDE="Runner: all wp/composer/php/node/npm commands via \`lando <cmd>\`. Never run on host."
echo "Chars: ${#COMPACT_GUIDE}"
'
```

The full session-start output (including project detection, design tool listing, and the compact guide) is typically 2,000–3,500 chars total depending on the project's active plans and detected tools.

---

## Model tier vs cost vs fidelity

Token efficiency isn't only *what's in context* — it's also *which model runs the
work*. Measured on an 8-prompt house-style holdout (hardest-convention subset, with
the plugin's rules delivered), per model:

| Tier | House-convention adherence | Relative cost |
|---|---|---|
| Claude Haiku 4.5 | 66% | 1× (cheapest) |
| Claude Sonnet 4.6 | 66% | ~4× Haiku |
| Claude Opus 4.8 | 86% | ~8× Haiku |

Takeaways for routing work:

- **On routine scaffolding, Haiku matches Sonnet.** For straightforward, well-specced
  block work, route to the cheaper tier — Sonnet doesn't buy fidelity over Haiku here.
- **The top tier earns its cost only on hard / ambiguous work.** Opus's jump to 86%
  shows up where deep reasoning matters (subtle conventions, novel layout decisions).
- **Suggested routing:** mechanical/clear → Haiku · architecture/ambiguous/"must be
  right" → Opus · Sonnet for a balanced middle.

> **Fidelity ≠ tokens.** A wireframe-to-production jump in a UI build came almost
> entirely from the **verify→fix loop** (see [how-to.md](how-to.md)), not from a
> bigger model or more generation tokens. The cheapest path to a *correct-looking*
> result is the loop, not the tier. Spend tier where judgement matters; spend
> iterations where fidelity matters.

### Caveat
The holdout is the hardest-convention subset with binary heuristic checks (n=8) —
directional, not a benchmark. On easy work the tiers converge; treat this as
"route down when you safely can," not a fixed rule.

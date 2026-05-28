# Implementing a Feature

This is the primary development loop: discovery → planning → building → review. Each phase has a hard gate — you don't skip to implementation until the previous phase is approved.

---

## The Loop

```
/architecture-discovery
       ↓ (approved spec)
/plan-generator
       ↓ (approved plan)
/building
       ↓ (each component verified)
/reviewing
       ↓ (convention audit passes)
   merge PR
```

---

## Phase 1 — `/architecture-discovery`

**Input:** Describe the feature in natural language. Be specific about what changes vs what stays the same.

```
/architecture-discovery
I need a filterable project portfolio section. It has a grid of project cards,
a category filter (CPT taxonomy), and a "load more" button that fetches via Livewire.
```

The `sage-architect` agent analyzes the description against the existing codebase and produces an **Architecture Decision Record (ADR)** with:
- Chosen approach and alternatives considered
- Component list with file paths
- Content model (CPT vs ACF vs Options classification)
- Integration points (hooks, routes, Livewire)

**Hard gate:** You review each section of the ADR and approve it before proceeding. The skill will not invoke `/plan-generator` automatically.

---

## Phase 2 — `/plan-generator`

**Input:** The approved ADR from Phase 1 (automatically read from the spec file).

```
/plan-generator
```

Produces a plan directory at `docs/plans/YYYY-MM-DD-<feature>/`:

```
docs/plans/2026-05-28-portfolio-section/
  plan.md          ← status, strategy, component list
  architecture.md  ← the ADR
  content-model.md ← static vs dynamic classification
  assets/          ← design reference images (populated by /designing)
  components/      ← sub-plans per component
  logs/            ← auto-populated by hooks
```

Review `plan.md` before building. Check that:
- Task order is logical (dependencies respected)
- File paths are exact, not approximate
- No "TBD" or "similar to Task N" placeholders

---

## Phase 3 — `/building`

**Input:** The active plan (auto-detected by `status: in-progress`).

```
/building
```

The skill reads the plan and implements task by task. After each component:
1. Runs verification (`lando php artisan acorn` + `lando theme-build`)
2. Checks for visual drift if a design reference exists
3. Stops for your review before the next task

**If something breaks mid-build:**

Run `/debugging`:
```
/debugging
Getting a Blade syntax error on the portfolio-card component —
Call to undefined method App\Blocks\PortfolioCard::withFields()
```

The `sage-debugger` agent will diagnose the issue and propose a fix without losing the build context.

**If visual drift is detected:**

Run `/verifying`:
```
/verifying
```

The `visual-verifier` agent captures screenshots via Playwright and compares against `assets/` images in the plan. It reports: match / drift / missing elements.

---

## Phase 4 — `/reviewing`

**Input:** The changed files (auto-detected from git diff, or you specify a path).

```
/reviewing
```

The `sage-reviewer` agent audits against Sage/Acorn conventions:
- ServiceProvider pattern (hooks in `boot()`, not `functions.php`)
- ACF Composer (no GUI-registered field groups)
- Poet for CPTs (no `register_post_type()`)
- Blade conventions (no PHP logic in templates)
- Security: nonces, capabilities, sanitization, escaping
- Tailwind v4: no `@apply` overuse, no arbitrary values that should be tokens

The review produces a pass/fail report per convention. Fix any failures before opening the PR.

---

## Decision Tree

```
Feature request received
        ↓
Is there already an active plan for this?
  YES → /building (read plan, continue)
  NO  →
        Is this a simple isolated change (single file, <2 hours)?
          YES → implement directly, then /reviewing
          NO  → /architecture-discovery → /plan-generator → /building → /reviewing
```

---

## Shortcuts for Simple Changes

For small changes that don't need a full ADR + plan:

```
/reviewing
Review the changes I just made to PortfolioCard.php before I commit.
```

```
/debugging
The `lando theme-build` output shows a Tailwind class not resolving —
bg-portfolio-gradient undefined.
```

These work standalone — no active plan required.

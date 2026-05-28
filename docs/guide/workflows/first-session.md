# First Session on a New Project

This guide covers what to do when you open a Sage project in Claude Code for the first time. The goal: understand the project state and decide what to work on next — in under 10 minutes.

---

## Step 1 — Run `/onboarding`

```
/onboarding
```

The `onboarding` skill analyzes the project and outputs a structured report. It detects:

| What | How |
|---|---|
| Theme path and Acorn version | Reads `composer.json` in the theme |
| Installed packages | Scans `composer.json` and `package.json` |
| Design tools | Checks for Paper/Figma/Stitch/Playwright MCP configurations |
| Active plans | Finds `docs/plans/*/plan.md` files with `status: in-progress` |
| Livewire | Checks if `acorn-livewire` is in dependencies |
| Lando | Verifies `.lando.yml` exists and Lando is available |

---

## Step 2 — Read the Output

The report ends with a **Suggested next step** section. Common scenarios:

### Scenario A: Active plan found

```
Active plan: docs/plans/2026-05-15-contact-section/plan.md
Suggested: run /building to continue from Task 3 (ContactBlock)
```

→ Run `/building`. The skill reads the plan and picks up where it left off.

### Scenario B: No plan, project is partially built

```
No active plan found.
Theme: web/app/themes/sage — Acorn 4.2, Livewire installed
Design tools: Paper configured, Playwright configured
Suggested: run /architecture-discovery to map the codebase before starting new work
```

→ Run `/architecture-discovery`. This produces an approved architecture spec before any implementation starts.

### Scenario C: Fresh project, nothing built yet

```
No active plan found.
Theme: web/app/themes/sage — Acorn 4.2
Suggested: start with /sage-design-system to establish tokens, then /architecture-discovery
```

→ Run `/sage-design-system` first if the design tokens and kitchensink page aren't set up. Then proceed to planning.

### Scenario D: Design tools not configured

```
Design tools: none configured
Suggested: configure Paper or Figma MCP (see README Design Tools section) before running /designing
```

→ Configure the relevant MCP server first. See the [README](../../../README.md) Design Tools section for install commands.

---

## Step 3 — Check `/sage-status` if Something Seems Off

If Lando containers aren't running or the stack versions look wrong:

```
/sage-status
```

This runs `lando info`, `lando wp core version`, PHP version, Acorn version, Node version, and prints active plan + design tool status — all in ≤ 20 lines.

---

## What Not to Do in a First Session

- **Don't run `/building` without a plan.** The `building` skill reads a plan file; without one it will ask you to create one first.
- **Don't run `/architecture-discovery` if an active plan already exists.** You'll create a second spec that conflicts with the in-progress plan.
- **Don't run `/designing` without a design tool configured.** The skill will detect the missing MCP and stop.

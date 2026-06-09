# How to use Superpowers Sage — a practical, step-by-step guide

This is the **hands-on** guide: what you do, the prompt you type, and the result
you should expect, in the order you actually use them. If you only read one page,
read this one.

> **The one rule that decides quality:** Superpowers Sage is a **loop**, not a
> code generator. Fidelity (a result that *looks like the design*, not a
> wireframe) comes from **build → verify → fix → repeat**, not from a single
> scaffold prompt. Treating the skills as one-shot generators produces
> wireframes. Running the loop produces production UI.

---

## The flow at a glance

```
/onboarding ──▶ /designing ──▶ /sage-design-system ──▶ /architecture-discovery
                                                                 │
                                                                 ▼
   ◀── /block-refactoring ◀── /reviewing ◀── /verifying ◀── /building ◀── /plan-generator
        (evolve)                (pre-PR)      (visual)       (implement)   (the plan)
```

- **Orient** → `/onboarding`
- **Foundation** → `/designing` (extract the design) then `/sage-design-system` (tokens + atoms)
- **Architect** → `/architecture-discovery` then `/plan-generator`
- **Build** → `/building` (executes the plan, block by block, **with verification**)
- **Verify** → `/verifying` (screenshot vs design → fix drift)
- **Ship** → `/reviewing` (convention audit before PR)
- **Evolve** → `/block-refactoring` (change an existing block)

> **For a whole feature/page, do NOT call `/block-scaffolding` per block by hand.**
> That skips the plan and the build-time verification loop — and that is exactly
> how you end up with a wireframe. `/block-scaffolding` is for **one** ad-hoc block.
> A page is `/architecture-discovery` → `/plan-generator` → `/building`.

---

## Step 1 — Orient: `/onboarding`

| | |
|---|---|
| **When** | First thing, every time you open a project. |
| **You type** | `/onboarding` |
| **Expected** | A report: theme path + Acorn version, installed packages, configured design tools (Paper/Figma/Playwright), any active plan, Lando status — and a **Suggested next step**. |
| **Tip** | On a fresh project it will route you to `/sage-design-system` first; on a project with a plan, to `/building`. Follow it. |

---

## Step 2 — Extract the design: `/designing`

| | |
|---|---|
| **When** | You have a Figma / Paper / Stitch / Pencil design to implement. |
| **You type** | `/designing https://www.figma.com/design/<fileKey>/<name>?node-id=<id>`<br>"Extract the global tokens and the list of homepage sections, in order." |
| **Expected** | Extracted design tokens (colours, **typography**, spacing, radius), a per-section reference, and reference screenshots used later by `/verifying`. |
| **Tip** | **Depth matters.** Let `/designing` pull the real computed styles and the structural reference — don't hand it a 5-line text summary. Garbage-in (a vague spec) → wireframe-out. Requires the design MCP (Figma needs a **Dev/Full** seat — a View seat cannot use the design tools). |

---

## Step 3 — Foundation: `/sage-design-system`

| | |
|---|---|
| **When** | Fresh project, before building any block. |
| **You type** | `/sage-design-system`<br>"Use the tokens extracted from the design. Build the `@theme` block in `resources/css/app.css` and a kitchensink page." |
| **Expected** | `@theme` tokens in `app.css` (Tailwind v4, no `tailwind.config.js`), reusable UI atoms (`x-ui.button`, etc.), and a `/kitchensink` page showing palette, type and buttons. |
| **Tip** | **Load the real fonts here, not later.** A perfect layout in the wrong font still reads as a wireframe. Add the brand fonts (e.g. via a `<link>` in the layout `<head>`) and point `--font-display` / `--font-sans` at them. Tokenize **every** design value (column widths, radii, section spacing) — the no-arbitrary rule depends on it. |

---

## Step 4 — Architect: `/architecture-discovery` → `/plan-generator`

| | |
|---|---|
| **When** | Starting a new feature or page (e.g. "the homepage"). |
| **You type** | `/architecture-discovery`<br>"I'm implementing the RideIn homepage (design already extracted). Map the theme and propose the architecture: which ACF Composer blocks, in what order, fields per block, and what's static vs a CPT." |
| **Then** | `/plan-generator` — "Generate the block-by-block implementation plan with a verification criterion per block." |
| **Expected** | An **approved architecture spec**, then `docs/plans/<date>-<feature>/plan.md` with one task per block and a "matches the design" check for each. |
| **Tip** | This is the step people skip — and it's the one that makes `/building` produce real UI instead of disconnected scaffolds. The plan is the contract `/building` executes against. |

---

## Step 5 — Build: `/building`

| | |
|---|---|
| **When** | You have a plan (from Step 4). |
| **You type** | `/building` |
| **Expected** | The skill works the plan **task by task** — scaffolds each block (ACF Composer class + Blade view), wires it in, and **verifies it against the design**, iterating until it matches. Resumes where it left off. |
| **Tip** | This is the workhorse. It calls block scaffolding and visual verification **for you**, inside the loop. Let it finish a block and verify before moving on — don't race ahead. Requires the **Playwright MCP** (it's how `/building` and `/verifying` see the result). |

---

## Step 6 — Verify: `/verifying`

| | |
|---|---|
| **When** | After each block (and `/building` runs it automatically). |
| **You type** | `/verifying`<br>"Compare the hero against section 1 of the design. Screenshot via Playwright, overlay the reference, and list spacing / colour / type / alignment drift." |
| **Expected** | A side-by-side (design × implementation) and a **drift list**, then targeted fixes. |
| **Tip** | **Mandatory, not optional.** This is where wireframe becomes production. Budget 2–4 verify→fix cycles per block. A blind run (no Playwright, no human looking) can only ever produce a first draft. |

---

## Step 7 — Ship: `/reviewing`

| | |
|---|---|
| **When** | Before opening a PR. |
| **You type** | `/reviewing` |
| **Expected** | A house-convention audit: ACF Composer shapes, Poet for CPTs, Tailwind v4 `@theme` (no arbitrary values), Blade (no shortcodes), escaping by field type — with a summary. |

---

## Step 8 — Evolve: `/block-refactoring`

| | |
|---|---|
| **When** | A block already exists and needs to change (v1 → v2, a new variant, a field added). |
| **You type** | `/block-refactoring`<br>"Evolve the hero: add a `badge` field above the headline and a `secondary_cta`." |
| **Expected** | A structured evolution of the existing block (fields, view, defaults) that preserves the conventions — not a rewrite. |

---

## When to use the ad-hoc skills (and when not to)

| Skill | Use it for | Do **not** use it for |
|---|---|---|
| `/block-scaffolding` | **One** new block, ad-hoc | A whole page/feature — use `/architecture-discovery` → `/plan-generator` → `/building` |
| `/designing` | Extracting a design | As a substitute for a hand-written spec — feed it the real design |
| `/modeling` | Deciding CPT vs ACF vs Options Page | — |
| `/debugging` | A Sage/Acorn/Lando/Livewire issue | — |
| `/migrating` | Moving data between fields/post types | — |

---

## Anti-patterns (learned the hard way)

1. **Scaffolding a whole page block-by-block by hand.** Skips the plan and the
   build-time verification loop → disconnected scaffolds, wireframe fidelity.
   Use the plan-driven flow.
2. **Skipping `/verifying`.** One-shot scaffolds are first drafts. Without the
   verify→fix loop the result *will* look like a wireframe, even on the best model.
3. **Building before the foundation.** No real fonts / no extracted tokens →
   correct layout, wrong look. Do `/designing` + `/sage-design-system` first.
4. **Shallow design input.** A 5-line text spec instead of the full `/designing`
   extraction caps the output at "structurally correct, visually generic."
5. **Generating blind.** If nothing can *see* the result (no Playwright, no human
   reviewing each step), you get drafts, not finals. Sight is the point.

> **Bottom line:** the value of Superpowers Sage is the **loop and the visual
> feedback**, not the scaffold. Orient → extract → foundation → plan → build →
> **verify → fix** → review. The scaffold is the cheap first draft; the loop is
> what makes it production.

---

See also: [first-session.md](workflows/first-session.md),
[implement-feature.md](workflows/implement-feature.md) (the plan-driven loop in
depth), [scaffold-block.md](workflows/scaffold-block.md), and the
[skills reference](skills.md).

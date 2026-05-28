# Agents Reference

Agents are **isolated subagent specialists** — each runs in its own context with a focused set of tools and skills. They are invoked by workflow skills automatically, or you can name them explicitly in a prompt.

All agents are namespaced as `superpowers-sage:<name>`.

---

## Core Agents

These agents are invoked by the primary workflow skills.

| Agent | Invoked by | Purpose | Input | Output |
|---|---|---|---|---|
| `sage-architect` | `/architecture-discovery` | Analyze feature requirements against Sage/Acorn conventions, produce Architecture Decision Records | Feature description, existing codebase context | ADR + component list + content model outline |
| `sage-reviewer` | `/reviewing` | Audit code against Sage/Acorn conventions: providers, hooks, ACF patterns, Blade structure | Changed files or PR diff | Annotated review with pass/fail per convention |
| `sage-debugger` | `/debugging` | Systematic diagnostics for Sage/Acorn/Lando issues — checks logs, configs, cache, autoload, service status | Error message or symptom description | Root cause + fix steps |
| `content-modeler` | `/modeling` | Classify content as static ACF fields, dynamic CPT collections, global Options Pages, or relational with Poet config | Component descriptions from design or spec | Content model table + Poet configuration snippets |
| `visual-verifier` | `/verifying` | Compare implementation screenshots against design reference using Playwright MCP | Plan spec files + reference images | Visual match report: match / drift / missing elements |
| `pencil-extractor` | `/designing` (for `.pen` files) | Extract design specs from Pencil `.pen` files; three modes: PANORAMIC (global tokens), SURGICAL (per section), COMPONENT_MAP (library bridge) | `.pen` file path or `design/` folder | Structured spec files: typography, colors, spacing, SVGs |

---

## Specialist Agents

These agents handle specific domains and are routed to by workflow skills when the context matches, or can be invoked directly.

| Agent | Invoked by | Purpose | Input | Output |
|---|---|---|---|---|
| `design-extractor` | `/designing` (for Paper/Figma/Stitch) | Extract precise design specs from Paper, Figma, or Stitch MCPs, or local reference images; PANORAMIC or SURGICAL mode | Design URL (Paper/Figma/Stitch) or image path | Spec files: typography, colors, spacing, SVG exports, layout |
| `forms` | `/sage-forms` or directly | Audit existing HTML Forms integrations against `sage-forms` skill patterns and apply fixes; or scaffold new standalone forms. Covers traps T1 (pattern backslash escaping), T2 (type=tel Chrome bug), T3 (ValidityState non-enumerable) | Blade form view path or "scaffold new form" prompt | Fix diff behind a single approval gate, or new form scaffold |
| `livewire-debugger` | `/debugging` (for Livewire issues) | Diagnose Livewire components that fail to mount, update, or emit events. Checks: component class, Blade bindings, CSRF middleware, network responses (419/403/500), Alpine.js conflicts, Livewire v2→v3 API changes | Component name or error description | Root cause + specific fix for the Livewire failure |
| `acorn-migration` | `/building` (for legacy theme migration) | Analyze procedural WordPress theme code and produce a phased migration plan to Acorn/Sage architecture. Detects `register_post_type` → Poet, `add_action/add_filter` → ServiceProvider, `$wpdb` → Eloquent, WP_Query → Eloquent scopes | `functions.php` path or theme directory | Phased migration plan with file-by-file recommendations |
| `tailwind-v4-auditor` | `/reviewing` | Audit Sage/Tailwind v4 projects across 5 categories: v3→v4 syntax, arbitrary value tokenization, PHP color-prop resolution, CSS variable cascade coverage, WP core layer conflicts | Theme directory | Severity-ranked report + dark-mode readiness score |

---

## Invoking Agents Directly

In Claude Code, agents appear in the command palette as `superpowers-sage:<name>`. You can also reference them in a prompt:

```
Use the livewire-debugger agent to investigate why my SearchBar component won't mount.
```

```
Ask the tailwind-v4-auditor to review the theme and report CSS variable cascade issues.
```

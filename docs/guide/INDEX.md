# Superpowers Sage — Usage Guide

This guide covers all features of the `superpowers-sage` plugin: workflow skills (invokable slash commands), reference skills (auto-loaded technical deep-dives), agents (isolated subagent specialists), slash commands, hooks (lifecycle automation), and token efficiency.

For installation and compatibility, see the [README](../../README.md).

---

## Quick Decision Table

| If you want to… | Run |
|---|---|
| Understand a new project | `/onboarding` |
| Discover + plan a new feature | `/architecture-discovery` → `/plan-generator` → `/building` |
| Set up design tokens and UI atoms | `/sage-design-system` |
| Implement from an existing plan | `/building` |
| Add a single new ACF block | `/block-scaffolding` |
| Evolve an existing block | `/block-refactoring` |
| Add a contact form to a block | `/block-scaffolding` (Phase 0c detects it) or `/sage-forms` |
| Extract design from Paper/Figma/Stitch/Pencil | `/designing` |
| Verify implementation matches design | `/verifying` |
| Review code before PR | `/reviewing` |
| Debug a Sage/Acorn/Lando issue | `/debugging` |
| Debug a Livewire component specifically | `/debugging` (routes to `livewire-debugger` agent) |
| Migrate data between fields or post types | `/migrating` |
| Model content: CPT vs ACF vs Options Page | `/modeling` |
| Set up AI/MCP tools | `/ai-setup` |
| Author a new MCP ability endpoint | `/abilities-authoring` |
| Install a WordPress plugin via Composer | `/install-plugin` |

---

## Reference

| File | What it covers |
|---|---|
| [skills.md](skills.md) | All 19 workflow skills · 17 reference skills · architectural preferences |
| [agents.md](agents.md) | All 11 agents — purpose, invocation, input, output |
| [commands.md](commands.md) | 3 slash commands: `/acf-register`, `/livewire-new`, `/sage-status` |
| [hooks.md](hooks.md) | Session-start, keyword router (32 entries), post-edit, diagnostics |
| [token-efficiency.md](token-efficiency.md) | How the plugin saves tokens + model-tier vs cost vs fidelity |
| [troubleshooting.md](troubleshooting.md) | Environment gotchas (Lando/Docker, ACF, Figma seat, fonts) — symptom → fix |

## Practical Guides

| File | What it covers |
|---|---|
| [how-to.md](how-to.md) | **Start here** — step-by-step: interactions × prompts × expected results |
| [workflows/first-session.md](workflows/first-session.md) | What to do in the first session on a new project |
| [workflows/implement-feature.md](workflows/implement-feature.md) | Full plan-driven feature loop from discovery to PR |
| [workflows/scaffold-block.md](workflows/scaffold-block.md) | New block scaffold, form integration, block refactoring |

# Superpowers Sage

Agent plugin for modern WordPress development with the **Roots ecosystem** — works with **Claude Code**, **VS Code (GitHub Copilot)**, **Cursor**, **OpenAI Codex**, and any AI assistant that supports the agent plugin format. Workflow skills, design tool integration, visual verification, content modeling, and zero-token automation hooks for **Sage**, **Acorn**, and **Lando** projects.

**[Full documentation →](https://hekivo.github.io/superpowers-sage/)**

## Prerequisites

| Requirement | Version |
|---|---|
| [Lando](https://lando.dev) | 3.x |
| [Sage](https://roots.io/sage/) + [Acorn](https://roots.io/acorn/) | 11+ / 4+ |
| PHP | 8.2+ |
| Node.js | 20+ |

## Installation

> **One repository, four loaders.** The same plugin installs identically regardless of your AI assistant. Pick the section for your tool below.

---

### Claude Code

```bash
claude plugin marketplace add codigodoleo/superpowers-sage
claude plugin install superpowers-sage@superpowers-sage
```

Alternatively, install directly from the repository URL:

```bash
claude plugin install --source https://github.com/codigodoleo/superpowers-sage
```

Verify the installation:

```bash
claude plugin list
```

---

### VS Code (GitHub Copilot Chat)

1. Enable the preview feature in your settings:

   ```json
   // settings.json
   "chat.plugins.enabled": true
   ```

2. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run:

   ```
   Chat: Install Plugin From Source
   ```

3. Enter the repository URL:

   ```
   https://github.com/codigodoleo/superpowers-sage
   ```

**Alternative — install via Extensions view:**  
Search `@agentPlugins` in the Extensions sidebar, or add the repository as a marketplace source in your settings:

```json
// settings.json
"chat.plugins.marketplaces": [
  "codigodoleo/superpowers-sage"
]
```

Then search for and install `superpowers-sage` from the Extensions view.

---

### Cursor

> **Note:** We consistently see significantly better results with **Claude CLI + Sonnet**. This plugin was designed around Claude Code's execution model — worktrees, hooks, subagent dispatch, MCP tool routing — and those features are unavailable in Cursor. You get the skill instructions, but none of the automation. If you have access to the Claude CLI, it's worth using that instead.

Recent Cursor versions removed the "paste repo URL" plugin installation UI. The reliable approach is a one-time clone + symlink:

```bash
# Clone once to a shared location
git clone https://github.com/codigodoleo/superpowers-sage ~/.ai-plugins/superpowers-sage

# In each project root, symlink into .cursor/rules/
ln -s ~/.ai-plugins/superpowers-sage/skills .cursor/rules/superpowers-sage-skills
ln -s ~/.ai-plugins/superpowers-sage/agents .cursor/rules/superpowers-sage-agents
```

On **Windows** (Command Prompt as Administrator):

```cmd
mklink /D .cursor\rules\superpowers-sage-skills %USERPROFILE%\.ai-plugins\superpowers-sage\skills
mklink /D .cursor\rules\superpowers-sage-agents %USERPROFILE%\.ai-plugins\superpowers-sage\agents
```

To update: `git -C ~/.ai-plugins/superpowers-sage pull` — all projects pick up changes automatically via the symlinks.

Cursor discovers skills and agents from `.cursor/rules/` automatically. Hooks are loaded from `hooks/cursor-hooks.json`.

---

### OpenAI Codex

The plugin ships with a `.codex-plugin/plugin.json` manifest that follows the
[Codex plugin format](https://developers.openai.com/codex/plugins/build).

**Personal install:**

1. Clone or symlink the repository into your Codex plugins directory:

   ```bash
   git clone https://github.com/codigodoleo/superpowers-sage ~/.codex/plugins/superpowers-sage
   ```

2. Register it in your personal marketplace at `~/.agents/plugins/marketplace.json`:

   ```json
   {
     "plugins": [
       { "name": "superpowers-sage", "source": "./superpowers-sage" }
     ]
   }
   ```

**Repo-level install** — drop the same entry into
`$REPO_ROOT/.agents/plugins/marketplace.json` and clone into
`$REPO_ROOT/plugins/superpowers-sage`.

Codex discovers skills from `skills/`, agents from `agents/`, and lifecycle
hooks from `hooks/hooks.json` (referenced from `.codex-plugin/plugin.json`).

---

### Local / Generic (any compatible assistant)

Clone the repository and register the plugin directory:

```bash
git clone https://github.com/codigodoleo/superpowers-sage ~/.ai-plugins/superpowers-sage
```

Then point your AI assistant to the cloned directory. For tools that support `chat.pluginLocations` (VS Code) or `--plugin-dir` (Claude Code):

```json
// VS Code settings.json
"chat.pluginLocations": {
  "/Users/you/.ai-plugins/superpowers-sage": true
}
```

```bash
# Claude Code — session-scoped
claude --plugin-dir ~/.ai-plugins/superpowers-sage
```

---

### Design Tools (optional)

These MCP integrations unlock the `/designing` and `/verifying` skills. Configure once per machine independent of which AI assistant you use:

`/designing` routes by the URL or path the user provides — `paper.design/*` → Paper MCP, `figma.com/*` → Figma, Stitch host → Stitch, or a local `.pen` path / `design/` folder → Pencil. Paper is the preferred cloud source when available.

```bash
# Paper.design (preferred) — screenshots + computed styles + JSX per section
# See https://paper.design for MCP install instructions

# Stitch (Google) — extract screens and sections from designs
claude mcp add stitch -- npx -y @anthropic/stitch-mcp

# Figma — extract frames and layers from designs
claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_KEY

# Pencil — local .pen file design tool (no URL — routes by file path or design/ folder)
claude mcp add pencil -- npx -y @anthropic/pencil-mcp

# Playwright — capture implementation screenshots for visual verification
claude mcp add playwright -- npx -y @anthropic/playwright-mcp
```

### Design tool routing

| Tool | Trigger | Token source | Structural reference |
|---|---|---|---|
| Paper | URL `paper.design/*` | `get_computed_styles` | `.reference.jsx` |
| Figma | URL `figma.com/*` | `get_variable_defs` | `get_design_context` |
| Stitch | Stitch host URL | `get_screen` | `get_screen` |
| Pencil | Path `*.pen` or `design/` folder | `get_variables()` | `batch_get` JSON |

### Pencil `.pen` file conventions

```
design/
  ├── design-system.lib.pen   ← global tokens — always read first
  ├── components.lib.pen      ← reusable component masters
  ├── component-map.md        ← generated by pencil-extractor (do not edit)
  └── [page-name].pen         ← one file per site route
```

Rules:
- `*.lib.pen` files are system/library files, never pages
- `*design-system*.lib.pen` has highest priority for token extraction
- `component-map.md` is generated — never edited manually

For VS Code, add MCP servers in `.vscode/mcp.json` or user settings under `"mcp"`.

---

## Compatibility Matrix

| Feature | Claude Code | VS Code Copilot | Cursor | Codex | Notes |
|---|---|---|---|---|---|
| Workflow skills (`/building`, etc.) | ✅ | ✅ | ✅ | ✅ | All loaders read `skills/` |
| Custom agents | ✅ | ✅ | ✅ | ✅ | All loaders read `agents/` |
| Hooks (lifecycle automation) | ✅ | ✅ | ✅ | ✅ | Claude/VS Code/Codex use `hooks/hooks.json`; Cursor uses `hooks/cursor-hooks.json` |
| MCP design tools | ✅ | ✅ | ✅ | ✅ | Configure per tool's MCP settings |
| Marketplace install | ✅ | ✅ | — | ✅ | Cursor installs direct from repository; Codex via `~/.agents/plugins/marketplace.json` |
| Namespaced skills | `superpowers-sage:building` | `superpowers-sage:building` | `/building` | `superpowers-sage:building` | Cursor may omit namespace prefix |

## Getting Started

After installing, open your Sage project and run:

```
/onboarding
```

This analyzes your project, detects installed packages, design tools, and active plans, then suggests next steps.

> **Plugin-level rules** live in [`CLAUDE.md`](CLAUDE.md) at the plugin
> root — universal Roots/Bedrock/Lando/Tailwind v4 constraints that
> apply to every session.

## Documentation

Full usage guide in [`docs/guide/`](docs/guide/):

| File | What it covers |
|---|---|
| [INDEX.md](docs/guide/INDEX.md) | Quick decision table + links to all sections |
| [skills.md](docs/guide/skills.md) | All 19 workflow skills + 17 reference skills + architectural preferences |
| [agents.md](docs/guide/agents.md) | All 11 agents — purpose, invocation, input, output |
| [commands.md](docs/guide/commands.md) | 3 slash commands: `/acf-register`, `/livewire-new`, `/sage-status` |
| [hooks.md](docs/guide/hooks.md) | Session-start behavior, keyword router (32 entries), diagnostics |
| [token-efficiency.md](docs/guide/token-efficiency.md) | How the plugin saves tokens — mechanism and contributor guidance |

### Practical guides

| File | What it covers |
|---|---|
| [workflows/first-session.md](docs/guide/workflows/first-session.md) | What to do in the first session on a new project |
| [workflows/implement-feature.md](docs/guide/workflows/implement-feature.md) | Full plan-driven feature loop from discovery to PR |
| [workflows/scaffold-block.md](docs/guide/workflows/scaffold-block.md) | New block scaffold, form integration, block refactoring |

## License

MIT

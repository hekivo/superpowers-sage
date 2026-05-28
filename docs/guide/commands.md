# Slash Commands

Slash commands are **fixed-script utilities** — distinct from skills, which are interactive guidance. Commands run a defined sequence of steps without LLM reasoning about approach.

Three commands ship with the plugin. They appear in the `/` command palette in Claude Code.

---

## `/acf-register`

Scaffolds a new ACF field group as a PHP class via Acorn's scaffolding command.

**When to use:** You need to add a new field group to the project and want the correct Acorn-managed class skeleton without typing the command manually.

**What it does:**
1. Asks: `Field group name? (e.g. HeroFields, PageSettings)`
2. Runs: `lando acorn acf:field <FieldGroupName>`
3. Reports the file created: `app/Fields/<FieldGroupName>.php`
4. Offers to open the file for editing

**Requirements:**
- Acorn installed (`lando acorn` available)
- ACF Pro active in the project
- Run from the theme root: `web/app/themes/<theme-name>/`

**Note:** This generates a code-managed field group, not an ACF GUI group. After scaffolding, define fields inside the class's `register()` method. See `acorn-eloquent` skill for field group patterns.

---

## `/livewire-new`

Scaffolds a new Livewire component via the plugin's create-component script.

**When to use:** You need a new Livewire component and want the correct Sage file locations without looking them up.

**What it does:**
1. Asks: `Component name? (e.g. SearchBar, UserProfile)`
2. Runs: `bash skills/acorn-livewire/scripts/create-component.sh <ComponentName>`
3. Reports both files created:
   - PHP class: `app/Http/Livewire/<ComponentName>.php`
   - Blade view: `resources/views/livewire/<component-name>.blade.php`

**Requirements:**
- Livewire installed in the project
- Run from the project root (where `skills/acorn-livewire/scripts/` is accessible)

**Note:** After scaffolding, wire properties and events using the `acorn-livewire` skill patterns.

---

## `/sage-status`

Reports Lando health, stack versions, active plan, and design tools for the current project. Useful at the start of a session to confirm everything is running before diving into work.

**What it runs:**

| Check | Command |
|---|---|
| Lando containers | `lando info` |
| WordPress version | `lando wp core version` |
| PHP version | `lando php -r "echo PHP_VERSION;"` |
| Acorn version | `lando theme-composer show roots/acorn` |
| Node version | `lando node --version` |
| Active plan | First `docs/plans/*/plan.md` with `status: in-progress` |
| Design tools | `node scripts/detect-design-tools.mjs` |

**Example output:**

```
### Lando Status
appserver  running
database   running
cache      running

### Stack Versions
WordPress: 6.8.1
PHP:       8.3.6
Acorn:     4.2.0
Node:      20.11.0

### Active Plan
docs/plans/2026-05-28-contact-block/plan.md

### Design Tools
Paper: configured · Playwright: configured · Figma: not configured
```

If a command fails, the output shows `unavailable` for that entry rather than stopping.

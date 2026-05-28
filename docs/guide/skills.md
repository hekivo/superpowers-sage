# Skills Reference

Skills are the core of the plugin. **Workflow skills** are user-invocable slash commands that guide you through activities. **Reference skills** are technical deep-dives loaded automatically when the keyword router detects relevant terms in your prompt, or explicitly when a workflow skill needs them.

---

## Workflow Skills

| Skill | Invoke with | When to use | Keyword router triggers |
|---|---|---|---|
| **onboarding** | `/onboarding` | First session on any project — analyze stack, packages, design tools, active plans | `project orientation`, `what exists in this project`, `first session` |
| **architecture-discovery** | `/architecture-discovery` | Deep architecture discovery with hard gates and section approvals | `map the codebase`, `discover the architecture` |
| **plan-generator** | `/plan-generator` | Convert an approved architecture spec into executable plan files | `generate the plan`, `write the plan` |
| **architecting** | `/architecting` | Alias — runs architecture-discovery then plan-generator in sequence | — |
| **modeling** | `/modeling` | Content architecture: classify static vs dynamic, recommend Poet/ACF/Options | — |
| **designing** | `/designing` | Design tool integration: Paper (preferred), Stitch, Figma, or local Pencil — routed by URL/path | `extract from figma`, `extract from pencil`, `paper.design url`, `pencil design` |
| **building** | `/building` | Plan-driven implementation with auto-verification after each component | `implement from the plan`, `build from the plan`, `execute the plan` |
| **block-scaffolding** | `/block-scaffolding` | Scaffold a new ACF block — 3 phases: design extraction, content modeling, form detection | `scaffold a block`, `new acf block` |
| **block-refactoring** | `/block-refactoring` | Evolve an existing block: fix drift, extend variants, v1→v2 migration | `refactor this block`, `block evolution`, `v1 to v2 migration` |
| **sage-design-system** | `/sage-design-system` | Bootstrap design tokens, kitchensink page, and global CSS variables | `design system tokens`, `kitchensink page`, `design system setup` |
| **verifying** | `/verifying` | Visual comparison: implementation screenshots vs design reference | `visual verification`, `compare to design`, `screenshot diff`, `design drift` |
| **reviewing** | `/reviewing` | Convention audit + design alignment check + pre-PR report | `review before pr`, `run a review`, `pre-pr review`, `convention audit` |
| **debugging** | `/debugging` | Sage-aware troubleshooting with cache, OPcache, and Livewire knowledge | `acorn boot error`, `blade rendering error`, `livewire mount fail`, `something is broken` |
| **migrating** | `/migrating` | Safe data migration scripts: post_content → ACF, field rename, post type migration | `post_content migration`, `acf field migration`, `data migration script` |
| **sage-forms** | `/sage-forms` | HTML Forms + Sage integration: `hf_get_form`, Blade form views, JS validation | `sage-html-forms`, `hf_get_form`, `html forms plugin` |
| **ai-setup** | `/ai-setup` | Install and configure AI/MCP tools: Acorn AI adapter, discover-abilities | `acorn ai`, `mcp adapter`, `discover-abilities`, `install mcp` |
| **abilities-authoring** | `/abilities-authoring` | Author new MCP ability endpoints via `make:ability` | `make:ability`, `execute-ability`, `acorn ability`, `mcp endpoint` |
| **install-plugin** | `/install-plugin` | Install WordPress plugins via Composer from `.zip` or `wp-packages.org` | — |
| **sageing** | `/sageing` | Meta skill — full architectural preferences and MCP query patterns | `which skill should i use`, `skill routing`, `full architectural preferences` |

> **Naming:** Skills use gerund form (`/building`, `/reviewing`) — the name describes the **activity**, not a shortcut.

---

## Reference Skills

Reference skills are **not** user-invocable. They are loaded by workflow skills and agents, or triggered by the keyword router when specific terms appear in your prompt. You can also invoke them explicitly if you know the name.

### Acorn Ecosystem

| Skill | Loaded when | Covers |
|---|---|---|
| `acorn-livewire` | `livewire component`, `wire:model`, `wire:click`, `make:livewire`, `livewire v3` | Livewire v3 component lifecycle, computed properties, Alpine.js integration, CSRF |
| `acorn-eloquent` | `eloquent model`, `model class`, `hasmany`, `belongsto`, `eloquent relationship` | Eloquent models in Acorn, scopes, eager loading, N+1 prevention |
| `acorn-queues` | `dispatch job`, `action scheduler`, `queue:work`, `queue job` | Action Scheduler, Laravel queues, job classes, failed job handling |
| `acorn-middleware` | `http middleware`, `acorn middleware`, `terminate()` | Middleware registration in Acorn, terminable middleware, kernel |
| `acorn-redis` | `redis cache`, `cache tags`, `cache driver`, `redis facade` | Redis cache driver, object cache drop-in, cache groups |
| `acorn-logging` | `log channel`, `monolog`, `logging config`, `log::error` | Monolog channels in Acorn, daily/stack drivers, custom handlers |
| `acorn-routes` | `acorn route`, `routes/web.php`, `register route` | Acorn Routes, named routes, route model binding |
| `acorn-commands` | — | Artisan commands in Acorn, `make:command`, scheduling |

### WordPress Core

| Skill | Loaded when | Covers |
|---|---|---|
| `wp-hooks-lifecycle` | `add_action`, `add_filter`, `hook priority`, `plugins_loaded`, `wptexturize`, `save_post hook` | Hook execution order, ServiceProvider boot() placement, Tailwind filter conflicts |
| `wp-rest-api` | `wp_rest_controller`, `rest endpoint`, `register_rest_route` | REST endpoint registration, authentication, permissions callbacks |
| `wp-capabilities` | `user capabilities`, `current_user_can`, `add_role`, `register_capability` | Roles, capabilities, multi-author setups, content restriction |
| `wp-security` | `sql injection`, `xss attack`, `nonce verification`, `sanitize_text_field`, `wp_kses`, `esc_html security` | Sanitize/escape/nonce/CSRF/capability checks, Bedrock secrets management |
| `wp-performance` | `transient cache`, `object cache`, `n+1 query`, `slow wp query`, `cache invalidation` | Query Monitor, N+1 patterns, autoloaded options, Redis, Core Web Vitals |
| `wp-cli-ops` | `wp eval`, `wp post list`, `wp option update`, `wp db query` | WP-CLI operations via Lando, bulk operations, database inspection |
| `wp-phpstan` | `phpcs`, `php codesniffer`, `phpstan`, `psalm`, `static analysis` | PHPStan levels, Psalm, PHPCS rules for WordPress/Sage projects |
| `wp-block-native` | `block.json`, `register_block_type`, `native block`, `wp:core`, `innerblocks` | Native Gutenberg blocks, `block.json` schema, InnerBlocks patterns |

### Theme + Tooling

| Skill | Loaded when | Covers |
|---|---|---|
| `sage-lando` | `lando start`, `lando stop`, `lando restart`, `lando ssh`, `lando info` | Lando services, recipes, debugging, custom services, port mapping |
| `sage-forms` | `sage-html-forms`, `hf_get_form`, `html forms plugin` | HTML Forms plugin + Blade bridge, form view routing, JS validation module, traps T1/T2/T3 |

---

## Architectural Preferences

The plugin enforces opinionated patterns for the Roots ecosystem. Workflow skills and agents will follow these by default.

| Scenario | Use | Avoid |
|---|---|---|
| Routes | Acorn Routes (`routes/web.php`) | `register_rest_route()` directly |
| Custom post types | Poet (`config/poet.php`) | `register_post_type()` |
| Fields and blocks | ACF Composer classes | ACF GUI |
| Background tasks | Action Scheduler / Laravel queue | Raw `wp-cron` scripts |
| Global config | ACF Options Pages | `wp_options` directly |
| Business logic | Service class or ServiceProvider | Fat controllers |
| Interactive UI | Livewire | Heavy custom JS |
| Static UI | Blade components | Shortcodes |
| Forms | HTML Forms plugin + sage-html-forms | CF7, Gravity Forms |
| Secrets | Bedrock `.env` | Hardcoded in PHP or version-controlled config |

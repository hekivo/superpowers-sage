# Block Workflows

This guide covers three block scenarios: scaffolding a new block, adding a contact form to a block, and refactoring an existing block.

---

## When to Use Which

| Situation | Skill |
|---|---|
| New block that doesn't exist yet | `/block-scaffolding` |
| Existing block needs new variants, fix drift, or new fields | `/block-refactoring` |
| You have a full feature plan and blocks are components of it | `/building` (auto-invokes `/block-scaffolding` per block) |
| Existing block needs a contact form added | `/block-scaffolding` (Phase 0c) or `/sage-forms` directly |
| Form in an existing block is broken or needs audit | `forms` agent directly |

---

## Scaffolding a New Block

```
/block-scaffolding
```

The skill runs in three phases, stopping for approval between each:

### Phase 0a — Design Reference Extraction

The skill asks which design tool is configured:
- **Paper/Figma/Stitch:** provide the URL — the `design-extractor` agent extracts typography, colors, spacing, and layout into spec files under `docs/plans/.../assets/`
- **Pencil:** provide the `.pen` file path — the `pencil-extractor` agent runs SURGICAL mode on the relevant section
- **No design tool:** provide a description and any screenshots — the skill proceeds with text spec only

Approval gate: confirm the extracted spec matches the design intent before continuing.

### Phase 0b — Content Modeling

The `content-modeler` agent classifies each field in the block:

| Classification | Implementation |
|---|---|
| Static field (text, image, color toggle) | ACF field in the block's Composer class |
| Repeatable items (card list, team members) | ACF Repeater or Flexible Content |
| Globally shared content (company name, social links) | ACF Options Page |
| Related content (related posts, project CPT) | Poet CPT + relationship field |

Approval gate: confirm the content model before the PHP class is generated.

### Phase 0c — Form Detection

The skill checks whether the block description or content model includes a contact/lead form. If detected:

1. Checks if `log1x/sage-html-forms` is installed (`lando theme-composer show log1x/sage-html-forms`)
2. If not installed → installs it: `lando composer require wpackagist-plugin/html-forms && lando theme-composer require log1x/sage-html-forms`
3. Scaffolds the HTML Forms plugin CPT entry, the Blade form view, and the JS validation module alongside the block

This is automatic — you don't need to run `/sage-forms` separately if you start with `/block-scaffolding`.

### Output

After all three phases:
- `app/Blocks/<BlockName>.php` — ACF Composer block class with all fields
- `resources/views/blocks/<block-slug>.blade.php` — block Blade view
- `resources/views/forms/<form-slug>.blade.php` — form view (Phase 0c only)
- `resources/js/blocks/<block-slug>.js` — block custom element JS (if interactive)
- `resources/js/modules/hf-validation.js` — validation module (Phase 0c, if not present)

---

## Adding a Form to an Existing Block

If a block already exists and you need to add a contact form:

```
/sage-forms
Add a contact form to the existing ContactSection block.
```

Or invoke the `forms` agent directly:

```
Use the forms agent to scaffold a contact form for the existing ContactSection block.
```

The `forms` agent:
1. Reads the existing block class and Blade view
2. Adds an `addPostObject` field scoped to the `html-form` CPT
3. Updates the block view to call `hf_get_form($form->ID)->get_html()`
4. Creates the Blade form view at `resources/views/forms/<form-slug>.blade.php`
5. Scaffolds the JS validation module if not present

### Form Integration Traps

Three documented bugs silently break forms in this stack. The `forms` agent checks for all three:

**T1 — `pattern` attribute backslash escaping**  
`$attributes->merge()` double-escapes backslashes; `patternMismatch` never fires.  
Fix: use a JS validator instead of a `pattern` attribute.

**T2 — `type="tel"` skips `patternMismatch` in Chrome**  
Use `type="text" inputmode="tel"` instead.

**T3 — `ValidityState` is non-enumerable**  
`{ ...field.validity }` and `Object.keys(validity)` return empty.  
Fix: access named properties directly — `validity.valueMissing`, `validity.patternMismatch`, etc.

---

## Refactoring an Existing Block

```
/block-refactoring
```

Use this when:
- A block was built with an older pattern and has accumulated drift vs the design
- You need to add new field variants (e.g., a new layout option)
- A v1 block needs to be upgraded to the v2 custom element architecture
- The block's Blade view has grown beyond its intended scope

The skill audits the existing block against current conventions and proposes a refactor plan. It will not rewrite the block — it stages the changes for your approval before writing any file.

**Do not use `/block-refactoring` for:**
- Adding a single new ACF field — do that directly in the Composer class
- Renaming a block — rename the PHP class, Blade view, and update any references manually
- Blocks that are already correct — run `/reviewing` to confirm, not `/block-refactoring`

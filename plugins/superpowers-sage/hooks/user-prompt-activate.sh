#!/usr/bin/env bash
# UserPromptSubmit hook: inject skill context when prompt matches exactly one skill keyword.
# Output: {"additionalContext":"..."} for a unique match. Silent on no-match or multi-match.

set -uo pipefail

HOOK_NAME="user-prompt-activate"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

INPUT="$(cat)"

# Extract prompt field — graceful on malformed JSON
PROMPT="$(echo "$INPUT" | grep -o '"prompt":[[:space:]]*"[^"]*"' | head -1 \
  | sed 's/"prompt":[[:space:]]*"//' | sed 's/"$//')" || PROMPT=""

[ -z "$PROMPT" ] && exit 0

PROMPT_LOWER="$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')"

# Format: "keyword1|keyword2:skill-name"
# Workflow skills: use slash-command names and domain-specific phrases as triggers
# Reference skills: use technical keywords that appear in real prompts
KEYWORD_MAP=(
  # --- Workflow skills ---
  "/onboarding|project orientation|what exists in this project|first session|onboard to this:onboarding"
  "/reviewing|sage-reviewer|run a review|review my block|pre-pr review|review before pr|convention audit:reviewing"
  "/debugging|lando logs show|acorn boot error|blade rendering error|livewire mount fail|debug this issue|something is broken:debugging"
  "/building|implement from the plan|build from the plan|execute the plan|building skill|start building:building"
  "/architecture-discovery|map the codebase|discover the architecture|architecture discovery:architecture-discovery"
  "/plan-generator|generate the plan|write the plan|plan-generator skill:plan-generator"
  "/designing|extract from figma|extract from pencil|design to blade|paper.design url|pencil design:designing"
  "/verifying|visual verification|compare to design|screenshot diff|design drift:verifying"
  "/migrating|post_content migration|acf field migration|data migration script:migrating"
  "/sage-design-system|design system tokens|kitchensink page|design system setup:sage-design-system"
  "/block-scaffolding|scaffold a block|new acf block|block-scaffolding skill:block-scaffolding"
  "/block-refactoring|refactor this block|block evolution|v1 to v2 migration|block refactor skill:block-refactoring"
  "/sageing|which skill should i use|skill routing|sage ecosystem|full architectural preferences:sageing"
  "/ai-setup|acorn ai|mcp adapter|discover-abilities|install mcp:ai-setup"
  "/abilities-authoring|make:ability|abilities-authoring|execute-ability|acorn ability|mcp endpoint|wp ability:abilities-authoring"
  # --- Reference skills ---
  "livewire component|wire:model|wire:click|make:livewire|livewire v3:acorn-livewire"
  "eloquent model|model class|eloquent query|hasmany|belongsto|eloquent relationship:acorn-eloquent"
  "block.json|register_block_type|native block|wp:core|innerblocks:wp-block-native"
  "lando start|lando stop|lando restart|lando ssh|lando info:sage-lando"
  "dispatch job|action scheduler|queue:work|queue job|horizon:acorn-queues"
  "http middleware|acorn middleware|terminate():acorn-middleware"
  "redis cache|cache tags|cache driver|redis facade:acorn-redis"
  "log channel|monolog|logging config|log::error|daily channel:acorn-logging"
  "acorn route|routes/web.php|register route:acorn-routes"
  "phpcs|php codesniffer|phpstan|psalm|static analysis:wp-phpstan"
  "wp_rest_controller|rest endpoint|register_rest_route:wp-rest-api"
  "user capabilities|current_user_can|add_role|register_capability|wp roles:wp-capabilities"
  "sql injection|xss attack|nonce verification|sanitize_text_field|wp_kses|esc_html security:wp-security"
  "transient cache|object cache|n+1 query|slow wp query|cache invalidation:wp-performance"
  "add_action|add_filter|hook priority|plugins_loaded|wptexturize|save_post hook:wp-hooks-lifecycle"
  "wp eval|wp post list|wp option update|wp db query:wp-cli-ops"
  "sage-html-forms|hf_get_form|html forms plugin|log1x/sage-html-forms:sage-forms"
)

MATCHED_SKILL=""
MATCH_COUNT=0

for entry in "${KEYWORD_MAP[@]}"; do
  keywords="${entry%%:*}"
  skill="${entry##*:}"
  IFS='|' read -ra kw_list <<< "$keywords"
  for kw in "${kw_list[@]}"; do
    if echo "$PROMPT_LOWER" | grep -qF "$kw" 2>/dev/null; then
      if [ "$MATCHED_SKILL" != "$skill" ]; then
        MATCHED_SKILL="$skill"
        MATCH_COUNT=$((MATCH_COUNT + 1))
      fi
      break
    fi
  done
done

if [ "$MATCH_COUNT" -ne 1 ]; then
  hook_info "Skill activation: $MATCH_COUNT match(es) — no injection"
  exit 0
fi

hook_info "Skill activation: injecting $MATCHED_SKILL"
printf '{"additionalContext":"Skill hint: %s skill is relevant. Invoke it if not already active."}\n' "$MATCHED_SKILL"
exit 0

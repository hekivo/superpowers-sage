#!/usr/bin/env bash
# SessionStart hook for superpowers-sage v1.0
# Detects Sage project, design tools, base skills, active plans
# Outputs health check with setup instructions for missing items

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

#############################################
# 1) Detect Sage project                    #
#############################################

DETECTION=""
if command -v node >/dev/null 2>&1; then
  DETECTION=$(node "${PLUGIN_ROOT}/scripts/detect-sage-project.mjs" --path "$(pwd)" 2>/dev/null || true)
fi

# Fallback: inline detection
if [ -z "$DETECTION" ] || [ "$(echo "$DETECTION" | head -c1)" != "{" ]; then
  FOUND=$(find . \( -path '*/.git*' -o -path '*/node_modules*' -o -path '*/vendor*' -o -path '*/storage*' \) -prune -o -type f -name "composer.json" -print 2>/dev/null | head -20 | xargs grep -l '"roots/acorn"' 2>/dev/null | head -1 || true)
  if [ -z "$FOUND" ]; then
    exit 0
  fi
  THEME_DIR=$(dirname "$FOUND")
  THEME_REL="${THEME_DIR#./}"
  DETECTION="{\"detected\":true,\"projects\":[{\"path\":\"${THEME_REL}\",\"type\":\"sage-theme\",\"acorn\":\"unknown\"}],\"lando\":{\"detected\":$([ -f .lando.yml ] && echo true || echo false)},\"activeProject\":\"${THEME_REL}\"}"
fi

DETECTED=$(echo "$DETECTION" | grep -o '"detected":\s*true' || true)
if [ -z "$DETECTED" ]; then
  exit 0
fi

#############################################
# 2) Parse project info                      #
#############################################

extract_json_value() {
  echo "$1" | grep -o "\"$2\":[[:space:]]*\"[^\"]*\"" | head -1 | sed "s/\"$2\":[[:space:]]*\"//" | sed 's/"$//'
}

ACTIVE_PROJECT=$(extract_json_value "$DETECTION" "activeProject")
ACORN_VER=$(echo "$DETECTION" | grep -o '"acorn":[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//' | sed 's/"$//')
LANDO_YML="no"
[ -f ".lando.yml" ] && LANDO_YML="yes (.lando.yml found)"

# Extract themes list
THEMES=""
for path in $(echo "$DETECTION" | grep -o '"path":"[^"]*"' | sed 's/"path":"//;s/"//g'); do
  THEMES="${THEMES}\n- ${path}"
done
[ -z "$THEMES" ] && THEMES="\n- ${ACTIVE_PROJECT:-unknown}"

# Detect Livewire
LIVEWIRE="no"
if [ -n "$ACTIVE_PROJECT" ] && [ -f "${ACTIVE_PROJECT}/composer.json" ]; then
  grep -q "acorn-livewire" "${ACTIVE_PROJECT}/composer.json" 2>/dev/null && LIVEWIRE="yes"
fi

#############################################
# 3) Detect design tools                    #
#############################################

DESIGN_TOOLS=""
if command -v node >/dev/null 2>&1; then
  DESIGN_TOOLS=$(node "${PLUGIN_ROOT}/scripts/detect-design-tools.mjs" --path "$(pwd)" 2>/dev/null || true)
fi

PAPER="no"
STITCH="no"
FIGMA="no"
PLAYWRIGHT="no"
CHROME="no"

if [ -n "$DESIGN_TOOLS" ]; then
  echo "$DESIGN_TOOLS" | grep -q '"paper".*"configured": true' 2>/dev/null && PAPER="yes"
  echo "$DESIGN_TOOLS" | grep -q '"stitch".*"configured": true' 2>/dev/null && STITCH="yes"
  echo "$DESIGN_TOOLS" | grep -q '"figma".*"configured": true' 2>/dev/null && FIGMA="yes"
  echo "$DESIGN_TOOLS" | grep -q '"playwright".*"configured": true' 2>/dev/null && PLAYWRIGHT="yes"
  echo "$DESIGN_TOOLS" | grep -q '"chrome".*"configured": true' 2>/dev/null && CHROME="yes"
fi

#############################################
# 4) Check base superpowers skills           #
#############################################

MISSING_SKILLS=""
BASE_SKILLS_DIR="${HOME}/.claude/skills"
for skill in brainstorming writing-plans executing-plans subagent-driven-development; do
  found=false
  # Check in ~/.claude/skills/ subdirectories
  for dir in "${BASE_SKILLS_DIR}"/*/; do
    [ -d "$dir" ] || continue
    if [ -f "${dir}${skill}/SKILL.md" ] || [ -f "${dir}skills/${skill}/SKILL.md" ]; then
      found=true
      break
    fi
  done
  if [ "$found" = false ]; then
    MISSING_SKILLS="${MISSING_SKILLS}\n  - ${skill}"
  fi
done

#############################################
# 5) Detect active plan                      #
#############################################

ACTIVE_PLAN=""
PLAN_TITLE=""
PLAN_ASSETS=""
PLANS_DIR="./docs/plans"

if [ -d "$PLANS_DIR" ]; then
  for dir in $(ls -1d "${PLANS_DIR}"/*/ 2>/dev/null | sort -r); do
    plan_file="${dir}plan.md"
    [ -f "$plan_file" ] || continue
    if grep -q "status: in-progress" "$plan_file" 2>/dev/null; then
      ACTIVE_PLAN="${dir%/}"
      PLAN_TITLE=$(grep -m1 "^title:" "$plan_file" | sed 's/^title:\s*//' | sed 's/^"//' | sed 's/"$//' 2>/dev/null || echo "Unknown")
      if [ -d "${dir}assets" ]; then
        ASSET_COUNT=$(ls -1 "${dir}assets/"*.png 2>/dev/null | wc -l || echo "0")
        PLAN_ASSETS="${ASSET_COUNT} reference images in ${ACTIVE_PLAN}/assets/"
      else
        PLAN_ASSETS="No assets yet"
      fi
      break
    fi
  done
fi

#############################################
# 6) First-run detection + MCP checklist     #
#############################################

FIRST_RUN=""
STATE_DIR=".superpowers-sage"
if [ ! -d "$STATE_DIR" ]; then
  mkdir -p "$STATE_DIR" 2>/dev/null || true
  FIRST_RUN="yes"
fi

SETUP_INSTRUCTIONS=""

if [ "$FIRST_RUN" = "yes" ]; then
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n\n🎉 **First run detected!** Here is your recommended MCP setup for this Sage project:\n"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| MCP | Purpose | Required | Install |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n|---|---|---|---|"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| Playwright | Visual verification (screenshots, DOM probes) | **Required** | \`claude mcp add playwright -- npx -y @anthropic/playwright-mcp\` |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| Paper | Preferred design tool (paper.design URLs) | Optional | https://paper.design |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| Figma | Alternative design tool (figma.com URLs) | Optional | \`claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_KEY\` |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| Stitch | Google Stitch design tool | Optional | \`claude mcp add stitch -- npx -y @anthropic/stitch-mcp\` |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n| Pencil | .pen design file support | Optional | see pencil MCP docs |"
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n\nAt minimum install Playwright — the \`/verifying\` and \`/building\` skills require it."
fi

if [ -n "$MISSING_SKILLS" ]; then
  SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n\n**Missing base skills:**${MISSING_SKILLS}\nInstall with: \`claude plugin install obra/superpowers\`"
fi

# Ongoing checklist (suppressed on first run to avoid duplication)
if [ "$FIRST_RUN" != "yes" ]; then
  if [ "$PAPER" = "no" ]; then
    SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n- Paper.design MCP (preferred): see https://paper.design for install instructions"
  fi
  if [ "$STITCH" = "no" ]; then
    SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n- Stitch MCP: \`claude mcp add stitch -- npx -y @anthropic/stitch-mcp\`"
  fi
  if [ "$FIGMA" = "no" ]; then
    SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n- Figma MCP: \`claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_KEY\`"
  fi
  if [ "$PLAYWRIGHT" = "no" ]; then
    SETUP_INSTRUCTIONS="${SETUP_INSTRUCTIONS}\n- Playwright MCP: \`claude mcp add playwright -- npx -y @anthropic/playwright-mcp\`"
  fi
fi

#############################################
# 7) Build compact skill routing summary     #
#############################################

COMPACT_GUIDE="Runner: all wp/composer/php/node/npm commands via \`lando <cmd>\`. Never run on host."
COMPACT_GUIDE="${COMPACT_GUIDE}\nCache: \`lando flush\` (PHP changes) · \`lando theme-build\` (CSS/JS changes)."
COMPACT_GUIDE="${COMPACT_GUIDE}\n"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Task | Invoke |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n|---|---|"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Understand project state | \`/onboarding\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Architecture + planning | \`/architecture-discovery\` then \`/plan-generator\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Implement from plan | \`/building\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Scaffold new ACF block | \`/block-scaffolding\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Refactor existing block | \`/block-refactoring\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Design → Blade/tokens | \`/designing\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Convention audit + PR | \`/reviewing\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Debug PHP/Blade/Livewire | \`/debugging\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Visual screenshot diff | \`/verifying\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Safe data migration | \`/migrating\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| Design system setup | \`/sage-design-system\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n| AI/MCP installation | \`/ai-setup\` |"
COMPACT_GUIDE="${COMPACT_GUIDE}\n"
COMPACT_GUIDE="${COMPACT_GUIDE}\nPreferred patterns: CPTs → Poet \xb7 Routes → Acorn Routes \xb7 Fields/Blocks → ACF Composer \xb7 Interactive UI → Livewire."
COMPACT_GUIDE="${COMPACT_GUIDE}\nFor full architectural preferences and MCP query patterns: invoke \`sageing\`."

#############################################
# 8) Build final context and output          #
#############################################

[ -n "$ACORN_VER" ] && [ "$ACORN_VER" != "unknown" ] && THEMES_EXTRA=" (Acorn v${ACORN_VER}, Livewire: ${LIVEWIRE})"

SUMMARY="Sage/Acorn project detected."
SUMMARY="${SUMMARY}\n\nLando: ${LANDO_YML}"
SUMMARY="${SUMMARY}\nDetected Sage themes:${THEMES}${THEMES_EXTRA:-}"
SUMMARY="${SUMMARY}\nDesign Tools: Paper: ${PAPER} | Stitch: ${STITCH} | Figma: ${FIGMA} | Playwright: ${PLAYWRIGHT} | Chrome: ${CHROME}"

if [ -n "$ACTIVE_PLAN" ]; then
  SUMMARY="${SUMMARY}\n\nActive Plan: ${ACTIVE_PLAN}/plan.md (${PLAN_TITLE}). Assets: ${PLAN_ASSETS}"
fi

if [ -n "$SETUP_INSTRUCTIONS" ]; then
  SUMMARY="${SUMMARY}\n\n--- Setup ---${SETUP_INSTRUCTIONS}"
fi

SUMMARY="${SUMMARY}\n\n${COMPACT_GUIDE}"
SUMMARY="${SUMMARY}\n\nTip: Run /onboarding for a full project analysis."

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\n${SUMMARY}\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0

#!/usr/bin/env bash
# =============================================================================
# AI Agent Kit — Setup para cualquier proyecto
# =============================================================================
# Crea la estructura mínima de skills, AGENTS.md, Engram y Copilot instructions
# para empezar a trabajar con agentes IA en un repo desde cero.
#
# Uso desde cualquier repo:
#   bash <(curl -sL https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/setup.sh)
#
# Con nombre y stealth:
#   bash <(curl -sL ...) --name "Mi App" --stealth
#
# Aceptar todo sin preguntar:
#   bash <(curl -sL ...) --yes
#
# Requisitos:
#   - Estar dentro de un repo Git
#   - Engram instalado (opcional)
# =============================================================================

set -e

# --- Colores ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${BLUE}ℹ${NC} $1"; }
ok()    { echo -e "${GREEN}✔${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✘${NC} $1"; exit 1; }

# --- Detectar root del repo ---
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || err "No estás dentro de un repo Git. Ejecutá 'git init' primero."
cd "$REPO_ROOT"

# --- Template base URL (para descargar skills si no hay directorio local) ---
TEMPLATE_BASE="https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/templates"

# --- Script dir (puede ser local si se clonó el repo) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_LOCAL="$SCRIPT_DIR/templates"

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     AI Agent Kit — Setup Interactivo     ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Parse args ---
PROJECT_NAME=""
STEALTH=0
YES_ALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --stealth) STEALTH=1; shift ;;
    --yes|-y) YES_ALL=1; shift ;;
    *) shift ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  DEFAULT_NAME="$(basename "$REPO_ROOT")"
  read -rp "$(echo -e "${CYAN}Nombre del proyecto${NC} [$DEFAULT_NAME]: ")" PROJECT_NAME
  PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"
fi

# --- Nombre kebab-case para skill ---
SKILL_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

info "Proyecto: ${BOLD}$PROJECT_NAME${NC}"
info "Skill principal: ${BOLD}$SKILL_NAME${NC}"

# --- Stack (detección automática) ---
FRAMEWORK="TODO"; LANGUAGE="TODO"

if [[ -f "package.json" ]]; then
  LANGUAGE="TypeScript/JavaScript"
  if grep -q '"next"' package.json 2>/dev/null; then FRAMEWORK="Next.js"; fi
  if grep -q '"react"' package.json 2>/dev/null && [[ "$FRAMEWORK" == "TODO" ]]; then FRAMEWORK="React"; fi
  if grep -q '"vue"' package.json 2>/dev/null; then FRAMEWORK="Vue"; fi
  if grep -q '"svelte"' package.json 2>/dev/null; then FRAMEWORK="Svelte"; fi
  if grep -q '"angular"' package.json 2>/dev/null; then FRAMEWORK="Angular"; fi
  if grep -q '"astro"' package.json 2>/dev/null; then FRAMEWORK="Astro"; fi
  if grep -q '"nuxt"' package.json 2>/dev/null; then FRAMEWORK="Nuxt"; fi
elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
  LANGUAGE="Python"
  if grep -q "django" pyproject.toml 2>/dev/null || grep -q "django" requirements.txt 2>/dev/null; then FRAMEWORK="Django"; fi
  if grep -q "fastapi" pyproject.toml 2>/dev/null || grep -q "fastapi" requirements.txt 2>/dev/null; then FRAMEWORK="FastAPI"; fi
  if grep -q "flask" pyproject.toml 2>/dev/null || grep -q "flask" requirements.txt 2>/dev/null; then FRAMEWORK="Flask"; fi
elif [[ -f "go.mod" ]]; then
  LANGUAGE="Go"
elif [[ -f "Cargo.toml" ]]; then
  LANGUAGE="Rust"
fi

info "Stack detectado: ${BOLD}$FRAMEWORK${NC} / ${BOLD}$LANGUAGE${NC}"
[[ $STEALTH -eq 1 ]] && info "Modo stealth: ${BOLD}activado${NC} (todo irá a .gitignore)"
echo ""

# --- Helper: ask yes/no ---
ask_yes_no() {
  local question="$1"
  if [[ $YES_ALL -eq 1 ]]; then return 0; fi
  local answer
  read -rp "$(echo -e "${CYAN}${question} [S/n]:${NC} ")" answer
  answer="${answer,,}" # lowercase
  [[ -z "$answer" || "$answer" == "s" || "$answer" == "si" || "$answer" == "sí" || "$answer" == "y" || "$answer" == "yes" ]]
}

# --- Helper: copy template (local or download) ---
copy_template() {
  local name="$1"
  local dest="skills/$name/SKILL.md"

  if [[ -f "$dest" ]]; then
    warn "$dest ya existe, saltando"
    return
  fi

  mkdir -p "skills/$name"

  # Try local first (cloned repo)
  if [[ -f "$TEMPLATES_LOCAL/$name/SKILL.md" ]]; then
    cp "$TEMPLATES_LOCAL/$name/SKILL.md" "$dest"
    ok "$dest"
    return
  fi

  # Download from GitHub
  if command -v curl &>/dev/null; then
    local url="$TEMPLATE_BASE/$name/SKILL.md"
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
      ok "$dest (descargado)"
      return
    fi
  fi

  warn "No se pudo obtener el template $name"
}

# =============================================================================
# Preguntar por skills opcionales
# =============================================================================
INSTALLED_SKILLS=()

echo -e "${BOLD}Skills opcionales detectadas para tu stack:${NC}"
echo ""

# React 19 — si framework es React/Next.js o lenguaje es TS/JS
if [[ "$FRAMEWORK" == "Next.js" || "$FRAMEWORK" == "React" || "$LANGUAGE" == "TypeScript/JavaScript" ]]; then
  if ask_yes_no "  ¿Instalar React 19?"; then
    INSTALLED_SKILLS+=("react-19|React 19 + React Compiler: sin memo, use(), useActionState, ref como prop|Escribir componentes React, hooks, usar use() o useActionState")
  fi
fi

# Next.js 16 Cache Components — si framework es Next.js
if [[ "$FRAMEWORK" == "Next.js" ]]; then
  if ask_yes_no "  ¿Instalar Next.js 16 Cache Components?"; then
    INSTALLED_SKILLS+=("next-cache-components|use cache, cacheLife, cacheTag, updateTag, PPR|Usar use cache, cacheTag, cacheLife o PPR")
  fi
fi

# TypeScript — si lenguaje es TS/JS
if [[ "$LANGUAGE" == "TypeScript/JavaScript" ]]; then
  if ask_yes_no "  ¿Instalar TypeScript?"; then
    INSTALLED_SKILLS+=("typescript|Convenciones TypeScript: strict, tipos, interfaces, generics|Escribir TypeScript, definir tipos o interfaces")
  fi
fi

# Token Optimization — siempre
if ask_yes_no "  ¿Instalar Token Optimization?"; then
  INSTALLED_SKILLS+=("token-optimization|Optimización de tokens: word budgets, lecturas paralelas, respuestas concisas|Respuestas verbosas, optimizar consumo de tokens")
fi

echo ""

# =============================================================================
# Crear archivos base (solo si no existen)
# =============================================================================

mkdir -p skills/_shared skills/"$SKILL_NAME" skills/skill-creator .github

# --- skills/_shared/common.md ---
if [[ ! -f "skills/_shared/common.md" ]]; then
cat > "skills/_shared/common.md" << 'EOF_COMMON'
---
name: common-patterns
description: >
  Patrones compartidos entre todas las skills del proyecto.
  Este archivo NO es una skill independiente — es referencia.
metadata:
  author: equipo
  version: "1.0"
  scope: [root]
---

# Patrones Compartidos

> Las skills referencian este archivo:
> `Ver skills/_shared/common.md § <sección>`

---

## § Naming (REQUIRED)

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Componentes | `PascalCase` | `ProductCard.tsx` |
| Archivos no-componente | `camelCase` | `formatDate.ts` |
| Carpetas de dominio | `lowercase` | `products`, `auth` |
| Skills | `kebab-case` | `mi-skill` |

---

## § Imports (REQUIRED)

```typescript
// ✅ Absolutos para cross-domain
import { MyComponent } from "@/components/MyComponent";

// ✅ Relativos dentro del mismo feature
import { helper } from "./helper";

// ❌ NUNCA importar desde archivo directo de otro dominio
import { helper } from "@/utils/format/formatDate";
```

---

## § Variables de Entorno (REQUIRED)

```typescript
// ✅ SIEMPRE leer dentro de funciones
export async function handler() {
  const key = process.env.SECRET_KEY;
}

// ❌ NUNCA a nivel de módulo
const key = process.env.SECRET_KEY;
```

---

## § Formato de Reglas en Skills

```markdown
## Nombre de la Regla (REQUIRED | RECOMMENDED)

\`\`\`typescript
// ✅ SIEMPRE: Hacer esto
// ❌ NUNCA: Hacer esto
\`\`\`

**Por qué?** Breve explicación.
```
EOF_COMMON
ok "skills/_shared/common.md"
else
  warn "skills/_shared/common.md ya existe, saltando"
fi

# --- Skill principal del proyecto ---
if [[ ! -f "skills/$SKILL_NAME/SKILL.md" ]]; then
cat > "skills/$SKILL_NAME/SKILL.md" << EOF_SKILL
---
name: $SKILL_NAME
description: >
  Convenciones generales del proyecto $PROJECT_NAME.
  Trigger: Al trabajar en cualquier parte del proyecto.
metadata:
  author: equipo
  version: "1.0"
  scope: [root]
  auto_invoke: "Trabajando en el proyecto $PROJECT_NAME"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# $PROJECT_NAME

> Patrones compartidos: ver \`skills/_shared/common.md\`

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | $FRAMEWORK |
| Lenguaje | $LANGUAGE |
| DB | TODO |
| Deploy | TODO |

---

## Estructura de carpetas

\`\`\`
src/
  components/     → Componentes UI
  services/       → Lógica de negocio
  utils/          → Funciones utilitarias
\`\`\`

> Editar con la estructura real del proyecto.

---

## Regla 1 — [Tu primera convención] (REQUIRED)

\`\`\`typescript
// ✅ Ejemplo correcto

// ❌ Ejemplo incorrecto
\`\`\`

**Por qué?** Explicar brevemente.
EOF_SKILL
ok "skills/$SKILL_NAME/SKILL.md"
else
  warn "skills/$SKILL_NAME/SKILL.md ya existe, saltando"
fi

# --- Skill creator ---
if [[ ! -f "skills/skill-creator/SKILL.md" ]]; then
cat > "skills/skill-creator/SKILL.md" << 'EOF_CREATOR'
---
name: skill-creator
description: >
  Guía para crear nuevas skills en el proyecto.
  Trigger: Cuando el usuario pide crear o documentar un patrón.
metadata:
  author: equipo
  version: "1.0"
  scope: [root]
  auto_invoke: "Crear nueva skill"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Cómo Crear Skills

## Estructura

```
skills/
  nombre-kebab-case/
    SKILL.md
```

## Template

```yaml
---
name: nombre-kebab-case
description: >
  Qué hace. Trigger: Cuándo se activa.
metadata:
  author: equipo
  version: "1.0"
  scope: [root]
  auto_invoke: "Descripción del trigger"
allowed-tools: Read, Edit, Write, Glob, Grep
---
```

## Checklist

- [ ] ¿El patrón se repite en más de un lugar?
- [ ] ¿No existe ya una skill que lo cubra?
- [ ] ¿Hay al menos 2 reglas con ejemplos ✅ / ❌?
- [ ] ¿Agregada a la tabla en AGENTS.md?
- [ ] ¿Trigger agregado a auto-invocación?
EOF_CREATOR
ok "skills/skill-creator/SKILL.md"
else
  warn "skills/skill-creator/SKILL.md ya existe, saltando"
fi

# =============================================================================
# Instalar skills opcionales
# =============================================================================
for entry in "${INSTALLED_SKILLS[@]}"; do
  IFS='|' read -r skill_name skill_desc skill_trigger <<< "$entry"
  copy_template "$skill_name"
done

# =============================================================================
# AGENTS.md (generado dinámicamente con skills instaladas)
# =============================================================================
if [[ ! -f "AGENTS.md" ]]; then

# Build skills table
SKILLS_TABLE="| \`$SKILL_NAME\` | Convenciones generales del proyecto | [SKILL.md](skills/$SKILL_NAME/SKILL.md) |"
for entry in "${INSTALLED_SKILLS[@]}"; do
  IFS='|' read -r skill_name skill_desc skill_trigger <<< "$entry"
  SKILLS_TABLE="$SKILLS_TABLE
| \`$skill_name\` | $skill_desc | [SKILL.md](skills/$skill_name/SKILL.md) |"
done
SKILLS_TABLE="$SKILLS_TABLE
| \`skill-creator\` | Cómo crear nuevas skills | [SKILL.md](skills/skill-creator/SKILL.md) |"

# Build auto-invoke table
AUTO_INVOKE="| Trabajar en cualquier parte del proyecto | \`$SKILL_NAME\` |"
for entry in "${INSTALLED_SKILLS[@]}"; do
  IFS='|' read -r skill_name skill_desc skill_trigger <<< "$entry"
  AUTO_INVOKE="$AUTO_INVOKE
| $skill_trigger | \`$skill_name\` |"
done
AUTO_INVOKE="$AUTO_INVOKE
| Crear una nueva skill o documentar un patrón | \`skill-creator\` |"

cat > "AGENTS.md" << EOF_AGENTS
# $PROJECT_NAME — Agent Guidelines

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | $FRAMEWORK |
| Lenguaje | $LANGUAGE |

---

## Skills disponibles

| Skill | Descripción | Archivo |
|-------|-------------|---------|
$SKILLS_TABLE

### Recursos compartidos

| Recurso | Descripción | Archivo |
|---------|-------------|--------|
| \`_shared/common\` | Patrones comunes: naming, imports, env vars | [common.md](skills/_shared/common.md) |

---

## Auto-invocación de skills

| Acción | Skill a cargar |
|--------|---------------|
$AUTO_INVOKE

---

## Notas para el agente

- Antes de generar código, leer la skill correspondiente.
- Las skills referencian \`skills/_shared/common.md\` para evitar repetir patrones.
- Si Engram está disponible, guardar decisiones importantes con \`mem_save\`.

---

## Comandos útiles

\`\`\`bash
# TODO: agregar comandos de dev, build, test
\`\`\`
EOF_AGENTS
ok "AGENTS.md"
else
  warn "AGENTS.md ya existe, saltando"
fi

# --- CLAUDE.md ---
if [[ ! -f "CLAUDE.md" ]]; then
  cp AGENTS.md CLAUDE.md
  ok "CLAUDE.md (copia de AGENTS.md)"
else
  warn "CLAUDE.md ya existe, saltando"
fi

# --- .github/copilot-instructions.md ---
if [[ ! -f ".github/copilot-instructions.md" ]]; then
  cp AGENTS.md ".github/copilot-instructions.md"
  ok ".github/copilot-instructions.md (copia de AGENTS.md)"
else
  warn ".github/copilot-instructions.md ya existe, saltando"
fi

# --- .gitignore ---
ADDED=0
GITIGNORE_LINES=(".vscode/mcp.json")
if [[ $STEALTH -eq 1 ]]; then
  GITIGNORE_LINES+=("AGENTS.md" "CLAUDE.md" ".github/copilot-instructions.md" "skills/" ".engram/")
fi
for line in "${GITIGNORE_LINES[@]}"; do
  if ! grep -qF "$line" .gitignore 2>/dev/null; then
    echo "$line" >> .gitignore
    ((ADDED++))
  fi
done
if [[ $ADDED -gt 0 ]]; then
  ok ".gitignore actualizado"
else
  ok ".gitignore ya configurado"
fi

# =============================================================================
# Engram
# =============================================================================
echo ""
ENGRAM_PATH=""

if command -v engram &>/dev/null; then
  ENGRAM_PATH="$(command -v engram)"
  ok "Engram encontrado: $ENGRAM_PATH"

  if [[ ! -f ".vscode/mcp.json" ]]; then
    mkdir -p .vscode

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
      WIN_PATH=$(cygpath -w "$ENGRAM_PATH" 2>/dev/null || echo "$ENGRAM_PATH")
      ESCAPED=$(echo "$WIN_PATH" | sed 's/\\/\\\\/g')
    else
      ESCAPED="$ENGRAM_PATH"
    fi

    cat > ".vscode/mcp.json" << MCP_EOF
{
  "servers": {
    "engram": {
      "command": "$ESCAPED",
      "args": ["mcp"]
    }
  }
}
MCP_EOF
    ok ".vscode/mcp.json (Engram MCP con ruta absoluta)"
  else
    warn ".vscode/mcp.json ya existe"
  fi
else
  warn "Engram no está instalado"
  info "Instalar: https://github.com/dleemiller/engram/releases"
  info "Después ejecutá este script de nuevo para configurar .vscode/mcp.json"
fi

# =============================================================================
# Resumen
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         AI Agent Kit — Listo ✔           ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Archivos creados:${NC}"
echo -e "  ${CYAN}AGENTS.md${NC}                          → Instrucciones para agentes"
echo -e "  ${CYAN}CLAUDE.md${NC}                          → Claude Code / OpenCode"
echo -e "  ${CYAN}.github/copilot-instructions.md${NC}    → VS Code Copilot"
echo -e "  ${CYAN}skills/_shared/common.md${NC}           → Patrones compartidos"
echo -e "  ${CYAN}skills/$SKILL_NAME/SKILL.md${NC}    → Skill principal"
echo -e "  ${CYAN}skills/skill-creator/SKILL.md${NC}      → Crear nuevas skills"
for entry in "${INSTALLED_SKILLS[@]}"; do
  IFS='|' read -r skill_name skill_desc skill_trigger <<< "$entry"
  echo -e "  ${CYAN}skills/$skill_name/SKILL.md${NC}    → $skill_desc"
done
[[ -n "$ENGRAM_PATH" ]] && echo -e "  ${CYAN}.vscode/mcp.json${NC}                   → Engram MCP (gitignored)"
if [[ $STEALTH -eq 1 ]]; then
  echo ""
  echo -e "  ${YELLOW}🥷 Modo stealth activo — todos los archivos están en .gitignore${NC}"
fi
echo ""
echo -e "${BOLD}Próximos pasos:${NC}"
echo -e "  1. Editar ${CYAN}skills/$SKILL_NAME/SKILL.md${NC} con tus convenciones"
echo -e "  2. Editar ${CYAN}AGENTS.md${NC} con comandos y stack real"
if [[ $STEALTH -eq 1 ]]; then
  echo -e "  3. Los archivos ya están en .gitignore — no se subirán al repo"
else
  echo -e "  3. Commitear:"
  echo -e "     ${YELLOW}git add AGENTS.md CLAUDE.md .github/ skills/ .gitignore${NC}"
  echo -e "     ${YELLOW}git commit -m \"feat: add AI agent kit [skip ci]\"${NC}"
fi
[[ -n "$ENGRAM_PATH" ]] && echo -e "  4. Reiniciar VS Code → Ctrl+Shift+P → MCP: List Servers"
echo ""

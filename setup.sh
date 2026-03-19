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
# O con nombre:
#   bash <(curl -sL https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/setup.sh) --name "Mi App"
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

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     AI Agent Kit — Setup Interactivo     ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Nombre del proyecto ---
PROJECT_NAME=""
STEALTH=0
for arg in "$@"; do
  if [[ "$arg" == "--stealth" ]]; then STEALTH=1; fi
done

if [[ "$1" == "--name" && -n "$2" ]]; then
  PROJECT_NAME="$2"
elif [[ "$2" == "--name" && -n "$3" ]]; then
  PROJECT_NAME="$3"
else
  DEFAULT_NAME="$(basename "$REPO_ROOT")"
  read -rp "$(echo -e "${CYAN}Nombre del proyecto${NC} [$DEFAULT_NAME]: ")" PROJECT_NAME
  PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"
fi

# --- Nombre kebab-case para skill ---
SKILL_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

info "Proyecto: ${BOLD}$PROJECT_NAME${NC}"
info "Skill principal: ${BOLD}$SKILL_NAME${NC}"
echo ""

# --- Stack (detección automática) ---
FRAMEWORK="TODO"; LANGUAGE="TODO"; PKG_MANAGER=""

if [[ -f "package.json" ]]; then
  LANGUAGE="TypeScript/JavaScript"
  if grep -q '"next"' package.json 2>/dev/null; then FRAMEWORK="Next.js"; fi
  if grep -q '"react"' package.json 2>/dev/null && [[ "$FRAMEWORK" == "TODO" ]]; then FRAMEWORK="React"; fi
  if grep -q '"vue"' package.json 2>/dev/null; then FRAMEWORK="Vue"; fi
  if grep -q '"svelte"' package.json 2>/dev/null; then FRAMEWORK="Svelte"; fi
  if grep -q '"angular"' package.json 2>/dev/null; then FRAMEWORK="Angular"; fi
  if grep -q '"astro"' package.json 2>/dev/null; then FRAMEWORK="Astro"; fi
  if grep -q '"nuxt"' package.json 2>/dev/null; then FRAMEWORK="Nuxt"; fi
  if [[ -f "pnpm-lock.yaml" ]]; then PKG_MANAGER="pnpm";
  elif [[ -f "yarn.lock" ]]; then PKG_MANAGER="yarn";
  elif [[ -f "bun.lockb" ]]; then PKG_MANAGER="bun";
  else PKG_MANAGER="npm"; fi
elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
  LANGUAGE="Python"
  if grep -q "django" pyproject.toml 2>/dev/null || grep -q "django" requirements.txt 2>/dev/null; then FRAMEWORK="Django"; fi
  if grep -q "fastapi" pyproject.toml 2>/dev/null || grep -q "fastapi" requirements.txt 2>/dev/null; then FRAMEWORK="FastAPI"; fi
  if grep -q "flask" pyproject.toml 2>/dev/null || grep -q "flask" requirements.txt 2>/dev/null; then FRAMEWORK="Flask"; fi
elif [[ -f "go.mod" ]]; then
  LANGUAGE="Go"
elif [[ -f "Cargo.toml" ]]; then
  LANGUAGE="Rust"
elif [[ -f "*.csproj" || -f "*.sln" ]]; then
  LANGUAGE="C#/.NET"
fi

info "Stack detectado: ${BOLD}$FRAMEWORK${NC} / ${BOLD}$LANGUAGE${NC}"
[[ $STEALTH -eq 1 ]] && info "Modo stealth: ${BOLD}activado${NC} (todo irá a .gitignore)"
echo ""

# =============================================================================
# Crear archivos (solo si no existen)
# =============================================================================

# --- skills/_shared/common.md ---
mkdir -p skills/_shared skills/"$SKILL_NAME" skills/skill-creator .github

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

Cada regla usa etiquetas de severidad y ejemplos con ✅ / ❌:

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

# --- AGENTS.md ---
if [[ ! -f "AGENTS.md" ]]; then
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
| \`$SKILL_NAME\` | Convenciones generales del proyecto | [SKILL.md](skills/$SKILL_NAME/SKILL.md) |
| \`skill-creator\` | Cómo crear nuevas skills | [SKILL.md](skills/skill-creator/SKILL.md) |

### Recursos compartidos

| Recurso | Descripción | Archivo |
|---------|-------------|--------|
| \`_shared/common\` | Patrones comunes: naming, imports, env vars | [common.md](skills/_shared/common.md) |

---

## Auto-invocación de skills

| Acción | Skill a cargar |
|--------|---------------|
| Trabajar en cualquier parte del proyecto | \`$SKILL_NAME\` |
| Crear una nueva skill o documentar un patrón | \`skill-creator\` |

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

    # Detectar OS para formato de ruta
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
echo -e "${BOLD}Para usarlo en otro repo:${NC}"
echo -e "  ${YELLOW}bash <(curl -sL https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/setup.sh)${NC}"
echo ""

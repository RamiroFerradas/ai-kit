# AI Agent Kit

Setup rápido de skills, memorias y configuraciones para trabajar con agentes IA en cualquier proyecto.

**Zero dependencies. Zero npm publish. Directo desde GitHub.**

## Instalación

Un solo comando desde cualquier repo Git:

```bash
npx github:RamiroFerradas/ai-kit
```

Con nombre del proyecto:

```bash
npx github:RamiroFerradas/ai-kit --name "Mi App"
```

### Modo stealth (ocultar del repo)

Agrega todos los archivos generados al `.gitignore` para que sean invisibles en el repo:

```bash
npx github:RamiroFerradas/ai-kit --stealth
npx github:RamiroFerradas/ai-kit --name "Mi App" --stealth
```

Los archivos siguen existiendo en tu máquina local pero no se commitean ni se suben al repo. Perfecto para trabajar con agentes IA sin que el sistema sea visible para otros.

> Requiere Node.js 18+ y estar dentro de un repo Git.

## Qué hace

Con un solo comando genera:

| Archivo | Para qué |
|---------|----------|
| `AGENTS.md` | Instrucciones para Claude Code, OpenCode, Gemini CLI |
| `CLAUDE.md` | Copia para Claude Code |
| `.github/copilot-instructions.md` | Instrucciones para VS Code Copilot |
| `skills/_shared/common.md` | Patrones compartidos (naming, imports, env vars) |
| `skills/<proyecto>/SKILL.md` | Skill principal con convenciones del proyecto |
| `skills/skill-creator/SKILL.md` | Guía para crear nuevas skills |
| `.vscode/mcp.json` | Engram MCP (si está instalado) |

## Uso

### One-liner (recomendado)

```bash
cd mi-proyecto
npx github:RamiroFerradas/ai-kit
```

### Alternativas

```bash
# Bash directo (sin Node.js)
bash <(curl -sL https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/setup.sh)

# Bash con stealth
bash <(curl -sL https://raw.githubusercontent.com/RamiroFerradas/ai-kit/main/setup.sh) --stealth

# Clonar una vez y reusar
git clone https://github.com/RamiroFerradas/ai-kit.git ~/.ai-kit
cd mi-proyecto && bash ~/.ai-kit/setup.sh
```

## Detección automática

El script detecta automáticamente:

- **Framework**: Next.js, React, Vue, Svelte, Angular, Astro, Nuxt, Django, FastAPI, Flask
- **Lenguaje**: TypeScript/JS, Python, Go, Rust, C#
- **Package manager**: npm, pnpm, yarn, bun
- **Engram**: Si está instalado, configura `.vscode/mcp.json` con ruta absoluta

## Engram (memoria persistente)

Si tenés [Engram](https://github.com/dleemiller/engram) instalado, el script configura automáticamente el MCP server para VS Code. Las memorias se sincronizan entre máquinas vía Git.

### Instalar Engram

```bash
# Windows: descargar de https://github.com/dleemiller/engram/releases
# Extraer engram.exe a C:\Users\<TU_USUARIO>\bin\
# Agregar al PATH

# Verificar:
engram version
```

### Sincronizar memorias

```bash
# Exportar (desde la máquina origen)
engram sync
git add .engram/ && git commit -m "chore: sync engram memories [skip ci]"
git push

# Importar (en la máquina destino)
git pull
engram sync --import
```

## Estructura generada

```
mi-proyecto/
├── .github/
│   └── copilot-instructions.md
├── .vscode/
│   └── mcp.json                  ← gitignored (ruta local)
├── AGENTS.md
├── CLAUDE.md
├── skills/
│   ├── _shared/
│   │   └── common.md
│   ├── mi-proyecto/
│   │   └── SKILL.md
│   └── skill-creator/
│       └── SKILL.md
└── .engram/                      ← se crea con `engram sync`
    ├── manifest.json
    └── chunks/
        └── xxxxxxxx.jsonl.gz
```

## Después del setup

1. Editar `skills/<proyecto>/SKILL.md` con las convenciones reales
2. Editar `AGENTS.md` con los comandos de dev/build/test
3. Commitear: `git add AGENTS.md CLAUDE.md .github/ skills/ .gitignore`
4. Agregar más skills según necesites (usar la skill `skill-creator`)
5. Reiniciar VS Code si Engram se configuró → `Ctrl+Shift+P` → MCP: List Servers

## Modo stealth — qué se ignora

Con `--stealth`, se agregan estas líneas al `.gitignore`:

```
AGENTS.md
CLAUDE.md
.github/copilot-instructions.md
skills/
.engram/
.vscode/mcp.json
```

Los archivos quedan solo en tu máquina local. Si trabajás en equipo, cada dev ejecuta el setup en su copia.

## Idempotente

El script es seguro de re-ejecutar. Si un archivo ya existe, lo saltea.

## Licencia

MIT

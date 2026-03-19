#!/usr/bin/env node
// =============================================================================
// AI Agent Kit — Setup para cualquier proyecto (Node.js cross-platform)
// =============================================================================

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const readline = require("readline");

// --- Colores ---
const c = {
  red: (s) => `\x1b[31m${s}\x1b[0m`,
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  blue: (s) => `\x1b[34m${s}\x1b[0m`,
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
};

const ok = (msg) => console.log(`${c.green("✔")} ${msg}`);
const info = (msg) => console.log(`${c.blue("ℹ")} ${msg}`);
const warn = (msg) => console.log(`${c.yellow("⚠")} ${msg}`);
const err = (msg) => {
  console.log(`${c.red("✘")} ${msg}`);
  process.exit(1);
};

// --- Detectar root del repo ---
let repoRoot;
try {
  repoRoot = execSync("git rev-parse --show-toplevel", { encoding: "utf8" }).trim();
} catch {
  err("No estás dentro de un repo Git. Ejecutá 'git init' primero.");
}
process.chdir(repoRoot);

// --- Detectar stack ---
function detectStack() {
  let framework = "TODO";
  let language = "TODO";

  if (fs.existsSync("package.json")) {
    const pkg = fs.readFileSync("package.json", "utf8");
    language = "TypeScript/JavaScript";
    if (pkg.includes('"next"')) framework = "Next.js";
    else if (pkg.includes('"react"')) framework = "React";
    else if (pkg.includes('"vue"')) framework = "Vue";
    else if (pkg.includes('"svelte"')) framework = "Svelte";
    else if (pkg.includes('"angular"')) framework = "Angular";
    else if (pkg.includes('"astro"')) framework = "Astro";
    else if (pkg.includes('"nuxt"')) framework = "Nuxt";
  } else if (fs.existsSync("requirements.txt") || fs.existsSync("pyproject.toml")) {
    language = "Python";
    const content = fs.existsSync("pyproject.toml")
      ? fs.readFileSync("pyproject.toml", "utf8")
      : fs.readFileSync("requirements.txt", "utf8");
    if (content.includes("django")) framework = "Django";
    else if (content.includes("fastapi")) framework = "FastAPI";
    else if (content.includes("flask")) framework = "Flask";
  } else if (fs.existsSync("go.mod")) {
    language = "Go";
  } else if (fs.existsSync("Cargo.toml")) {
    language = "Rust";
  }

  return { framework, language };
}

// --- Detectar Engram ---
function findEngram() {
  try {
    const cmd = process.platform === "win32" ? "where engram" : "which engram";
    return execSync(cmd, { encoding: "utf8" }).trim().split("\n")[0];
  } catch {
    return null;
  }
}

// --- Escribir archivo solo si no existe ---
function writeIfNew(filePath, content) {
  const full = path.resolve(filePath);
  const dir = path.dirname(full);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  if (fs.existsSync(full)) {
    warn(`${filePath} ya existe, saltando`);
    return false;
  }
  fs.writeFileSync(full, content, "utf8");
  ok(filePath);
  return true;
}

// --- Agregar línea a .gitignore si no está ---
function ensureGitignore(line) {
  const file = ".gitignore";
  const content = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
  if (!content.includes(line)) {
    fs.appendFileSync(file, `\n${line}\n`);
    return true;
  }
  return false;
}

// --- Prompt interactivo ---
function ask(question, defaultValue) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const prompt = defaultValue ? `${question} [${defaultValue}]: ` : `${question}: `;
    rl.question(c.cyan(prompt), (answer) => {
      rl.close();
      resolve(answer.trim() || defaultValue || "");
    });
  });
}

// --- Kebab-case ---
function toKebab(str) {
  return str.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

// =============================================================================
// Templates
// =============================================================================

const COMMON_MD = `---
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
> \`Ver skills/_shared/common.md § <sección>\`

---

## § Naming (REQUIRED)

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Componentes | \`PascalCase\` | \`ProductCard.tsx\` |
| Archivos no-componente | \`camelCase\` | \`formatDate.ts\` |
| Carpetas de dominio | \`lowercase\` | \`products\`, \`auth\` |
| Skills | \`kebab-case\` | \`mi-skill\` |

---

## § Imports (REQUIRED)

\`\`\`typescript
// ✅ Absolutos para cross-domain
import { MyComponent } from "@/components/MyComponent";

// ✅ Relativos dentro del mismo feature
import { helper } from "./helper";

// ❌ NUNCA importar desde archivo directo de otro dominio
import { helper } from "@/utils/format/formatDate";
\`\`\`

---

## § Variables de Entorno (REQUIRED)

\`\`\`typescript
// ✅ SIEMPRE leer dentro de funciones
export async function handler() {
  const key = process.env.SECRET_KEY;
}

// ❌ NUNCA a nivel de módulo
const key = process.env.SECRET_KEY;
\`\`\`

---

## § Formato de Reglas en Skills

\`\`\`markdown
## Nombre de la Regla (REQUIRED | RECOMMENDED)

\\​\`\\​\`\\​\`typescript
// ✅ SIEMPRE: Hacer esto
// ❌ NUNCA: Hacer esto
\\​\`\\​\`\\​\`

**Por qué?** Breve explicación.
\`\`\`
`;

function skillMd(name, projectName, framework, language) {
  return `---
name: ${name}
description: >
  Convenciones generales del proyecto ${projectName}.
  Trigger: Al trabajar en cualquier parte del proyecto.
metadata:
  author: equipo
  version: "1.0"
  scope: [root]
  auto_invoke: "Trabajando en el proyecto ${projectName}"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# ${projectName}

> Patrones compartidos: ver \`skills/_shared/common.md\`

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | ${framework} |
| Lenguaje | ${language} |
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
`;
}

const SKILL_CREATOR = `---
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

\`\`\`
skills/
  nombre-kebab-case/
    SKILL.md
\`\`\`

## Template

\`\`\`yaml
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
\`\`\`

## Checklist

- [ ] ¿El patrón se repite en más de un lugar?
- [ ] ¿No existe ya una skill que lo cubra?
- [ ] ¿Hay al menos 2 reglas con ejemplos ✅ / ❌?
- [ ] ¿Agregada a la tabla en AGENTS.md?
- [ ] ¿Trigger agregado a auto-invocación?
`;

function agentsMd(projectName, skillName, framework, language) {
  return `# ${projectName} — Agent Guidelines

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | ${framework} |
| Lenguaje | ${language} |

---

## Skills disponibles

| Skill | Descripción | Archivo |
|-------|-------------|---------|
| \`${skillName}\` | Convenciones generales del proyecto | [SKILL.md](skills/${skillName}/SKILL.md) |
| \`skill-creator\` | Cómo crear nuevas skills | [SKILL.md](skills/skill-creator/SKILL.md) |

### Recursos compartidos

| Recurso | Descripción | Archivo |
|---------|-------------|--------|
| \`_shared/common\` | Patrones comunes: naming, imports, env vars | [common.md](skills/_shared/common.md) |

---

## Auto-invocación de skills

| Acción | Skill a cargar |
|--------|---------------|
| Trabajar en cualquier parte del proyecto | \`${skillName}\` |
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
`;
}

// =============================================================================
// Main
// =============================================================================
async function main() {
  console.log("");
  console.log(c.bold(c.cyan("╔══════════════════════════════════════════╗")));
  console.log(c.bold(c.cyan("║     AI Agent Kit — Setup Interactivo     ║")));
  console.log(c.bold(c.cyan("╚══════════════════════════════════════════╝")));
  console.log("");

  // Parse args
  const args = process.argv.slice(2);
  let projectName;
  const nameIdx = args.indexOf("--name");
  if (nameIdx !== -1 && args[nameIdx + 1]) {
    projectName = args[nameIdx + 1];
  } else {
    const defaultName = path.basename(repoRoot);
    projectName = await ask("Nombre del proyecto", defaultName);
  }

  const skillName = toKebab(projectName);
  const { framework, language } = detectStack();

  info(`Proyecto: ${c.bold(projectName)}`);
  info(`Skill principal: ${c.bold(skillName)}`);
  info(`Stack detectado: ${c.bold(framework)} / ${c.bold(language)}`);
  console.log("");

  // --- Crear archivos ---
  writeIfNew("skills/_shared/common.md", COMMON_MD);
  writeIfNew(`skills/${skillName}/SKILL.md`, skillMd(skillName, projectName, framework, language));
  writeIfNew("skills/skill-creator/SKILL.md", SKILL_CREATOR);

  const agentsContent = agentsMd(projectName, skillName, framework, language);
  writeIfNew("AGENTS.md", agentsContent);

  if (!fs.existsSync("CLAUDE.md")) {
    fs.writeFileSync("CLAUDE.md", agentsContent);
    ok("CLAUDE.md");
  } else {
    warn("CLAUDE.md ya existe, saltando");
  }

  if (!fs.existsSync(".github/copilot-instructions.md")) {
    fs.mkdirSync(".github", { recursive: true });
    fs.writeFileSync(".github/copilot-instructions.md", agentsContent);
    ok(".github/copilot-instructions.md");
  } else {
    warn(".github/copilot-instructions.md ya existe, saltando");
  }

  // .gitignore
  if (ensureGitignore(".vscode/mcp.json")) {
    ok(".gitignore actualizado");
  } else {
    ok(".gitignore ya configurado");
  }

  // --- Engram ---
  console.log("");
  const engramPath = findEngram();

  if (engramPath) {
    ok(`Engram encontrado: ${engramPath}`);

    if (!fs.existsSync(".vscode/mcp.json")) {
      fs.mkdirSync(".vscode", { recursive: true });

      // Formato de ruta según OS
      const escapedPath =
        process.platform === "win32"
          ? engramPath.replace(/\\/g, "\\\\")
          : engramPath;

      const mcpConfig = JSON.stringify(
        { servers: { engram: { command: escapedPath, args: ["mcp"] } } },
        null,
        2
      );
      fs.writeFileSync(".vscode/mcp.json", mcpConfig + "\n");
      ok(".vscode/mcp.json (Engram MCP con ruta absoluta)");
    } else {
      warn(".vscode/mcp.json ya existe");
    }
  } else {
    warn("Engram no está instalado");
    info("Instalar: https://github.com/dleemiller/engram/releases");
    info("Después re-ejecutá este setup para configurar .vscode/mcp.json");
  }

  // --- Resumen ---
  console.log("");
  console.log(c.bold(c.green("╔══════════════════════════════════════════╗")));
  console.log(c.bold(c.green("║         AI Agent Kit — Listo ✔           ║")));
  console.log(c.bold(c.green("╚══════════════════════════════════════════╝")));
  console.log("");
  console.log(c.bold("Archivos creados:"));
  console.log(`  ${c.cyan("AGENTS.md")}                          → Agentes IA`);
  console.log(`  ${c.cyan("CLAUDE.md")}                          → Claude Code`);
  console.log(`  ${c.cyan(".github/copilot-instructions.md")}    → VS Code Copilot`);
  console.log(`  ${c.cyan("skills/_shared/common.md")}           → Patrones compartidos`);
  console.log(`  ${c.cyan(`skills/${skillName}/SKILL.md`)}    → Skill principal`);
  console.log(`  ${c.cyan("skills/skill-creator/SKILL.md")}      → Crear nuevas skills`);
  if (engramPath) {
    console.log(`  ${c.cyan(".vscode/mcp.json")}                   → Engram MCP`);
  }
  console.log("");
  console.log(c.bold("Próximos pasos:"));
  console.log(`  1. Editar ${c.cyan(`skills/${skillName}/SKILL.md`)} con tus convenciones`);
  console.log(`  2. Editar ${c.cyan("AGENTS.md")} con comandos y stack real`);
  console.log(`  3. Commitear:`);
  console.log(`     ${c.yellow('git add AGENTS.md CLAUDE.md .github/ skills/ .gitignore')}`);
  console.log(`     ${c.yellow('git commit -m "feat: add AI agent kit [skip ci]"')}`);
  if (engramPath) {
    console.log(`  4. Reiniciar VS Code → Ctrl+Shift+P → MCP: List Servers`);
  }
  console.log("");
}

main().catch((e) => {
  err(e.message);
});

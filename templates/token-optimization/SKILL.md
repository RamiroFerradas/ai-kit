---
name: token-optimization
description: >
  Optimización de tokens en interacciones con agentes IA — word budgets, lecturas paralelas, respuestas concisas.
  Trigger: Al notar respuestas excesivamente largas o repetición de contexto.
metadata:
  author: ai-kit
  version: "1.0"
  scope: [root]
  auto_invoke: "Optimizar tokens, reducir verbosidad del agente"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Token Optimization

Directrices para reducir el consumo de tokens en interacciones con agentes IA sin perder calidad de respuesta.

---

## Principio #1 — Shared Boilerplate (REQUIRED)

Las skills referencian patrones comunes desde `skills/_shared/common.md` en vez de repetirlos.

```markdown
// ✅ En una skill: referenciar
> Patrones compartidos: ver `skills/_shared/common.md`

// ❌ Repetir patrones de imports/naming en cada skill
```

---

## Principio #2 — Word Budgets para Artefactos (RECOMMENDED)

Límites de palabras para outputs del agente:

| Artefacto | Máximo |
|-----------|--------|
| Resumen de cambios | 100 palabras |
| Explicación de un bug | 150 palabras |
| Plan de implementación | 200 palabras |
| Descripción de PR | 150 palabras |
| Comentario de código | 1 línea, solo si la lógica no es obvia |
| Skill SKILL.md | 800 palabras (sin contar código) |

```
// ✅ Respuesta concisa
Creado `fetchBrands.ts` con cache tag `brands`. Barrel actualizado.

// ❌ Respuesta verbosa
He procedido a crear un nuevo archivo llamado fetchBrands.ts dentro de la carpeta
app/services/products/queries/. Este archivo implementa una función que utiliza el
cliente de Supabase para servidor para obtener las marcas de productos...
```

---

## Principio #3 — Lecturas Paralelas (REQUIRED)

Leer múltiples archivos en paralelo cuando son independientes:

```
// ✅ Una llamada: leer 4 archivos en paralelo
read_file(services/index.ts) || read_file(helpers/index.ts) || read_file(models/index.ts)

// ❌ Lectura secuencial innecesaria
read_file(services/index.ts)
→ esperar resultado
read_file(helpers/index.ts)
→ esperar resultado
```

---

## Principio #4 — Pre-resolver Skills (REQUIRED)

El `AGENTS.md` lista el path exacto de cada skill. El agente NO debe buscar skills — ya tiene los paths.

```
// ✅ Leer directamente desde el path conocido
read_file("skills/react-19/SKILL.md")

// ❌ Buscar "cuál skill usar para React"
semantic_search("react skill") → leer resultado → leer skill
```

---

## Principio #5 — Engram como Caché de Decisiones (RECOMMENDED)

Si Engram está disponible, guardar decisiones para no re-descubrirlas:

```
// ✅ Guardar una vez, leer siempre
mem_save("El proyecto usa path alias @/ configurado en tsconfig.json")

// ❌ Buscar el path alias en cada sesión
grep_search("@/") → leer tsconfig → deducir alias → repetir mañana
```

---

## Checklist

- [ ] ¿Las skills referencian `_shared/common.md` en vez de repetir patrones?
- [ ] ¿Las respuestas respetan los word budgets?
- [ ] ¿Las lecturas de archivos son paralelas cuando son independientes?
- [ ] ¿El agente usa los paths directos de AGENTS.md?
- [ ] ¿Se guardan decisiones en Engram para futuras sesiones?

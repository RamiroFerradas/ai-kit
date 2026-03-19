---
name: engram-memory
description: >
  Uso obligatorio de Engram como memoria persistente entre sesiones.
  Trigger: Al inicio y fin de CADA sesión, y cada vez que se descubra algo importante.
license: Apache-2.0
metadata:
  author: ai-kit
  version: "1.0"
  scope: [root]
  auto_invoke: "Inicio de sesión, fin de sesión, descubrimiento importante"
allowed-tools: Read, Edit, Write, Glob, Grep, Engram
---

# Engram — Memoria Persistente Obligatoria

Engram es la memoria del proyecto entre sesiones. **Todo lo que no se guarda, se pierde.**

---

## Al Inicio de Cada Sesión (REQUIRED)

```
mem_context(project="<nombre-proyecto>") → recuperar contexto previo
```

Esto carga decisiones, bugs, patrones y descubrimientos de sesiones anteriores.
**SIEMPRE hacerlo ANTES de empezar a trabajar.**

> **Si Engram no responde**: buscar tools con patrón `mcp_engram` usando tool_search. Los tools se llaman `mcp_engram_mem_save`, `mcp_engram_mem_context`, etc. Si aún no aparecen, pedir al usuario: Ctrl+Shift+P → "MCP: List Servers" → verificar que Engram esté "running".

---

## Durante la Sesión — Qué Guardar (REQUIRED)

Guardar con `mem_save` **INMEDIATAMENTE** cuando ocurra:

| Evento | type | Ejemplo de title |
|--------|------|-----------------|
| Bug encontrado y fix | `bugfix` | "Fix: build falla por barrel vacío" |
| Decisión de arquitectura | `architecture` | "Services usan use cache con cacheTag" |
| Patrón descubierto | `pattern` | "Labels de shadcn/ui usan htmlFor con id" |
| Config o workaround | `config` | "Prebuild ESLint: no usar comillas simples en Windows" |
| Refactor importante | `refactor` | "Carousel barrel limpiado: removido carouselData" |
| Nueva skill o regla | `architecture` | "Skill pre-commit-checks creada" |

### Formato de content

```
**What**: Qué se hizo o descubrió
**Why**: Por qué era necesario
**Where**: Archivos o rutas afectadas
**Learned**: Lección para el futuro (opcional)
```

### Ejemplo Completo

```
mem_save(
  title="Fix: tests admin fallan por copy desactualizado",
  type="bugfix",
  project="MiProyecto",
  content="**What**: 3 tests admin fallaban porque los componentes cambiaron labels pero los tests no se actualizaron\n**Why**: Refactor de UI sin actualizar tests\n**Where**: __test__/components/admin/\n**Learned**: Siempre actualizar tests cuando se cambia copy de componentes"
)
```

---

## Al Finalizar la Sesión (REQUIRED)

```
mem_session_end(summary="Resumen breve de lo hecho en la sesión")
```

---

## Reglas

1. **NUNCA** terminar una sesión sin haber guardado las observaciones importantes
2. **NUNCA** empezar a trabajar sin `mem_context` primero
3. Preferir **muchas observaciones cortas** a pocas largas
4. Usar `mem_search` cuando necesites buscar algo específico de sesiones pasadas
5. Usar `mem_stats` para verificar que las memorias se están acumulando

---

## Verificación Rápida

Al final de cada sesión, preguntarse:
- [ ] ¿Ejecuté `mem_context` al inicio?
- [ ] ¿Guardé cada bug/fix con `mem_save`?
- [ ] ¿Guardé cada decisión de arquitectura?
- [ ] ¿Guardé cada workaround o config?
- [ ] ¿Ejecuté `mem_session_end` con resumen?

---
name: typescript
description: >
  Convenciones de TypeScript: strict mode, tipos, interfaces, generics y buenas prácticas.
  Trigger: Al escribir TypeScript, definir tipos o interfaces.
metadata:
  author: ai-kit
  version: "1.0"
  scope: [root]
  auto_invoke: "Escribir TypeScript, definir tipos o interfaces"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# TypeScript Conventions

---

## Strict Mode (REQUIRED)

Siempre habilitar las opciones de strict en `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

---

## Type vs Interface (RECOMMENDED)

- `type` para uniones, intersecciones, tipos primitivos y tipos mapeados
- `interface` para objetos y clases que se extienden

```typescript
// ✅ type para uniones
type Status = "active" | "inactive" | "pending";
type Result<T> = { success: true; data: T } | { success: false; error: string };

// ✅ interface para objetos
interface User {
  id: string;
  name: string;
  email: string;
}

// ✅ interface cuando se extiende
interface AdminUser extends User {
  role: "admin";
  permissions: string[];
}

// ❌ NUNCA: type para objetos que se extienden
type User = { id: string; name: string };
type AdminUser = User & { role: "admin" }; // Usar interface + extends
```

---

## Evitar `any` (REQUIRED)

Usar `unknown` en lugar de `any`. Forzar narrowing explícito.

```typescript
// ✅ unknown + narrowing
function parseInput(input: unknown): string {
  if (typeof input === "string") return input;
  if (typeof input === "number") return String(input);
  throw new Error("Tipo no soportado");
}

// ❌ NUNCA
function parseInput(input: any): string {
  return input; // Sin validación
}
```

---

## Named Exports (REQUIRED)

Preferir named exports. Los default exports no proporcionan autocompletado confiable.

```typescript
// ✅ Named export
export function formatDate(date: Date): string { ... }
export interface Product { ... }

// ❌ Default export
export default function formatDate(date: Date): string { ... }
```

**Excepción**: `page.tsx`, `layout.tsx`, `loading.tsx` en Next.js App Router requieren default export.

---

## Utility Types (RECOMMENDED)

Usar utility types de TypeScript en lugar de redefinir tipos:

```typescript
// ✅ Utility types
type PartialUser = Partial<User>;
type UserName = Pick<User, "name" | "email">;
type UserWithoutId = Omit<User, "id">;
type UserMap = Record<string, User>;

// ❌ Redefinir manualmente
interface PartialUser {
  id?: string;
  name?: string;
  email?: string;
}
```

---

## Funciones — Tipos explícitos en APIs públicas (RECOMMENDED)

Declarar tipos de retorno en funciones exportadas. Dejar inferir en funciones internas.

```typescript
// ✅ Tipo de retorno explícito en función exportada
export function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// ✅ Tipo inferido en función interna (private)
function formatLine(item: CartItem) {
  return `${item.name}: $${item.price}`;
}

// ❌ Tipo de retorno en función interna trivial
function add(a: number, b: number): number {
  return a + b;
}
```

---

## Generics — Nombres descriptivos (RECOMMENDED)

Usar nombres descriptivos para generics cuando `T` no es suficiente.

```typescript
// ✅ Descriptivo cuando hay múltiples generics
function merge<TBase, TOverride>(base: TBase, override: TOverride): TBase & TOverride {
  return { ...base, ...override };
}

// ✅ T está bien para un solo generic simple
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

// ❌ Letras sueltas con múltiples generics
function merge<A, B>(base: A, override: B): A & B { ... }
```

---

## Enums — Evitar (RECOMMENDED)

Preferir `as const` objects o union types sobre enums.

```typescript
// ✅ Union type
type Direction = "up" | "down" | "left" | "right";

// ✅ Const object cuando necesitás valores
const STATUS = {
  ACTIVE: "active",
  INACTIVE: "inactive",
  PENDING: "pending",
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS];

// ❌ Enum — genera código runtime innecesario
enum Direction {
  Up = "up",
  Down = "down",
}
```

---

## Checklist TypeScript

- [ ] ¿`strict: true` habilitado en tsconfig?
- [ ] ¿No hay `any` en el código?
- [ ] ¿Se usan named exports (excepto pages de Next.js)?
- [ ] ¿Interfaces para objetos, types para uniones?
- [ ] ¿Utility types en vez de redefinir tipos?
- [ ] ¿Tipos de retorno explícitos en funciones exportadas?

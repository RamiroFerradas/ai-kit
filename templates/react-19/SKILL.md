---
name: react-19
description: >
  React 19 + React Compiler patterns: sin memoización manual, use(), useActionState, ref como prop.
  Trigger: Al escribir componentes o hooks React con React 19.
metadata:
  author: ai-kit
  version: "1.0"
  scope: [root, ui]
  auto_invoke: "Escribir componentes o hooks React con React 19"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# React 19

React 19 introduce el **React Compiler** que optimiza automáticamente los componentes. Esto elimina la necesidad de `useMemo`, `useCallback` y `memo` en la mayoría de los casos.

---

## Sin Memoización Manual (REQUIRED)

El React Compiler optimiza los re-renders automáticamente. No usar `useMemo`, `useCallback` ni `memo` salvo casos excepcionales documentados.

```typescript
// ✅ SIEMPRE: el Compiler lo optimiza solo
function Component({ items }: { items: Item[] }) {
  const filtered = items.filter((x) => x.active);
  const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));

  const handleClick = (id: string) => {
    console.log(id);
  };

  return <List items={sorted} onClick={handleClick} />;
}

// ❌ NUNCA: memoización manual innecesaria
const filtered = useMemo(() => items.filter((x) => x.active), [items]);
const handleClick = useCallback((id: string) => console.log(id), []);
```

**Por qué?** El React Compiler analiza el grafo de dependencias en build time. Agregar `useMemo`/`useCallback` manualmente interfiere con el compilador y agrega ruido al código.

---

## Imports (REQUIRED)

```typescript
// ✅ SIEMPRE: named imports
import { useState, useEffect, useRef, use, useActionState } from "react";

// ❌ NUNCA
import React from "react";
import * as React from "react";
```

---

## Server Components Primero (REQUIRED)

Por defecto, todos los componentes son Server Components. Solo agregar `"use client"` cuando sea estrictamente necesario.

```typescript
// ✅ Server Component (sin directiva) — fetch directo
export default async function ProductsPage() {
  const products = await fetchProducts();
  return <ProductList products={products} />;
}

// ✅ Client Component — solo cuando se necesita interactividad
"use client";
export function AddToCartButton({ productId }: { productId: string }) {
  const [added, setAdded] = useState(false);
  return (
    <button onClick={() => setAdded(true)}>
      {added ? "Agregado ✓" : "Agregar al carrito"}
    </button>
  );
}
```

### Cuándo usar `"use client"`

- `useState`, `useEffect`, `useRef`, `useContext`
- Event handlers (`onClick`, `onChange`, `onSubmit`)
- APIs del browser (`window`, `localStorage`, `navigator`)
- Librerías que requieren DOM (sliders, drag & drop)

---

## Hook `use()` — Leer Promesas y Contexto (RECOMMENDED)

```typescript
import { use } from "react";

// Leer una promesa — suspende hasta que resuelve
function Reviews({ promise }: { promise: Promise<Review[]> }) {
  const reviews = use(promise);
  return reviews.map((r) => <ReviewCard key={r.id} review={r} />);
}

// Leer contexto condicionalmente (imposible con useContext)
function ThemeLabel({ showTheme }: { showTheme: boolean }) {
  if (showTheme) {
    const theme = use(ThemeContext);
    return <span style={{ color: theme.primary }}>Con tema</span>;
  }
  return <span>Sin tema</span>;
}
```

---

## `useActionState` — Formularios con estado (RECOMMENDED)

```typescript
"use server";
async function updateItem(prevState: unknown, formData: FormData) {
  const name = formData.get("name") as string;
  await saveItem({ name });
  return { success: true };
}

// En el Client Component
"use client";
import { useActionState } from "react";

function ItemForm() {
  const [state, action, isPending] = useActionState(updateItem, null);

  return (
    <form action={action}>
      <input name="name" required />
      <button disabled={isPending}>
        {isPending ? "Guardando..." : "Guardar"}
      </button>
      {state?.success && <p>Guardado correctamente</p>}
    </form>
  );
}
```

---

## `ref` como Prop — Sin `forwardRef` (REQUIRED)

En React 19, `ref` es simplemente una prop más. No usar `forwardRef`.

```typescript
// ✅ React 19: ref es una prop normal
function Input({ ref, ...props }: React.ComponentProps<"input">) {
  return <input ref={ref} {...props} />;
}

// Uso
const inputRef = useRef<HTMLInputElement>(null);
<Input ref={inputRef} placeholder="Buscar..." />;

// ❌ Forma antigua — innecesaria en React 19
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => (
  <input ref={ref} {...props} />
));
```

---

## Checklist React 19

- [ ] ¿No hay `useMemo` / `useCallback` / `memo` innecesarios?
- [ ] ¿Los imports son named (`import { useState } from "react"`)?
- [ ] ¿El componente es Server Component por defecto (sin directiva)?
- [ ] ¿`"use client"` se usa solo cuando hay interactividad o APIs del browser?
- [ ] ¿Se usa `ref` como prop directamente (sin `forwardRef`)?
- [ ] ¿Los formularios con estado usan `useActionState`?

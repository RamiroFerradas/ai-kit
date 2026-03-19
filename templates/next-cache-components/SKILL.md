---
name: next-cache-components
description: >
  Next.js 16 Cache Components — PPR, directiva use cache, cacheLife, cacheTag y updateTag.
  Trigger: Al usar use cache, cacheTag, cacheLife, revalidar rutas o implementar PPR.
metadata:
  author: ai-kit
  version: "1.0"
  scope: [root]
  auto_invoke: "Usar use cache, cacheTag, cacheLife o PPR"
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Cache Components (Next.js 16+)

Cache Components enable Partial Prerendering (PPR) — mix static, cached, and dynamic content in a single route.

## Habilitar Cache Components

```ts
// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  cacheComponents: true,
}

export default nextConfig
```

Reemplaza el viejo flag `experimental.ppr`.

---

## Tres Tipos de Contenido

### 1. Estático (Auto-Prerendered)

Código sincrónico, imports, computaciones puras — prerendered en build time:

```tsx
export default function Page() {
  return (
    <header>
      <h1>Blog</h1> {/* Static - instant */}
      <nav>...</nav>
    </header>
  )
}
```

### 2. Cached (`use cache`)

Datos async que no necesitan fetch fresco en cada request:

```tsx
async function BlogPosts() {
  'use cache'
  cacheLife('hours')

  const posts = await db.posts.findMany()
  return <PostList posts={posts} />
}
```

### 3. Dinámico (Suspense)

Datos runtime que deben estar frescos — envolver en Suspense:

```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <>
      <BlogPosts />  {/* Cached */}

      <Suspense fallback={<p>Cargando...</p>}>
        <UserPreferences />  {/* Dynamic - streams in */}
      </Suspense>
    </>
  )
}

async function UserPreferences() {
  const theme = (await cookies()).get('theme')?.value
  return <p>Tema: {theme}</p>
}
```

---

## Directiva `use cache`

### A nivel de archivo

```tsx
'use cache'

export default async function Page() {
  const data = await fetchData()
  return <div>{data}</div>
}
```

### A nivel de componente

```tsx
export async function CachedComponent() {
  'use cache'
  const data = await fetchData()
  return <div>{data}</div>
}
```

### A nivel de función

```tsx
export async function getData() {
  'use cache'
  return db.query('SELECT * FROM posts')
}
```

---

## Perfiles de Cache — `cacheLife()`

Perfiles built-in: `'default'`, `'minutes'`, `'hours'`, `'days'`, `'weeks'`, `'max'`

```tsx
import { cacheLife } from 'next/cache'

async function getData() {
  'use cache'
  cacheLife('hours')
  return fetch('/api/data')
}
```

### Configuración inline

```tsx
async function getData() {
  'use cache'
  cacheLife({
    stale: 3600,      // 1 hora — servir stale mientras revalida
    revalidate: 7200, // 2 horas — intervalo de revalidación background
    expire: 86400,    // 1 día — expiración hard
  })
  return fetch('/api/data')
}
```

---

## Invalidación de Cache

### `cacheTag()` — Taggear contenido cacheado

```tsx
import { cacheTag } from 'next/cache'

async function getProducts() {
  'use cache'
  cacheTag('products')
  return db.products.findMany()
}

async function getProduct(id: string) {
  'use cache'
  cacheTag('products', `product-${id}`)
  return db.products.findUnique({ where: { id } })
}
```

### `updateTag()` — Invalidación inmediata

```tsx
'use server'

import { updateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.products.update({ where: { id }, data })
  updateTag(`product-${id}`)  // Inmediato — el mismo request ve data fresca
}
```

### `revalidateTag()` — Revalidación background

```tsx
'use server'

import { revalidateTag } from 'next/cache'

export async function createPost(data: FormData) {
  await db.posts.create({ data })
  revalidateTag('posts')  // Background — el próximo request ve data fresca
}
```

---

## Restricción de Runtime Data

**No se puede** acceder a `cookies()`, `headers()` o `searchParams` dentro de `use cache`.

### Solución: Pasar como argumentos

```tsx
// ❌ Incorrecto — API de runtime dentro de use cache
async function CachedProfile() {
  'use cache'
  const session = (await cookies()).get('session')?.value  // Error!
}

// ✅ Correcto — extraer afuera, pasar como argumento
async function ProfilePage() {
  const session = (await cookies()).get('session')?.value
  return <CachedProfile sessionId={session} />
}

async function CachedProfile({ sessionId }: { sessionId: string }) {
  'use cache'
  const data = await fetchUserData(sessionId)
  return <div>{data.name}</div>
}
```

---

## Migración desde Versiones Anteriores

| Config vieja | Reemplazo |
|-----------|-------------|
| `experimental.ppr` | `cacheComponents: true` |
| `dynamic = 'force-dynamic'` | Remover (comportamiento default) |
| `dynamic = 'force-static'` | `'use cache'` + `cacheLife('max')` |
| `revalidate = N` | `cacheLife({ revalidate: N })` |
| `unstable_cache()` | Directiva `'use cache'` |

---

## Limitaciones

- **Edge runtime no soportado** — requiere Node.js
- **Static export no soportado** — necesita server
- **Valores no determinísticos** (`Math.random()`, `Date.now()`) se ejecutan una vez en build time dentro de `use cache`

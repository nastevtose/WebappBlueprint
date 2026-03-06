# Frontend Guidelines

## Goal

Build a **web-first app** with Next.js + TypeScript, structured so core logic is portable to a future React Native / Expo mobile app.

Priority: ship the web app cleanly → keep business logic portable → avoid web-only assumptions in shared code → do not over-engineer for mobile now.

---

## Stack

| Concern | Choice |
|---|---|
| Framework | Next.js (App Router) |
| Language | TypeScript — strict mode always on |
| Styling | Tailwind CSS |
| Validation | Zod (shared client + server) |
| Data fetching | `fetch` (server components), TanStack Query (client) |
| Forms | React Hook Form + Zod when forms are complex |
| Testing | Vitest for unit/integration, Playwright for e2e |
| Linting | ESLint + Prettier |

---

## Layer Architecture

Keep these four layers separated — never mix concerns across them:

- **UI layer** → pages, layouts, components, form rendering
- **Application layer** → orchestration, use cases, feature flows
- **Domain layer** → business rules, entities, transformations — no UI, no fetch
- **Infrastructure layer** → API calls, HTTP clients, adapters, storage

---

## Project Structure

```
src/
  app/                        # Next.js routes, layouts, route handlers only
    api/
  components/
    ui/                       # Generic design-system primitives
  features/
    <feature>/
      components/             # Feature UI
      hooks/                  # Feature hooks
      api/                    # Feature-scoped API calls
      domain/                 # Feature business logic
      schemas/                # Zod schemas for this feature
      mappers/                # DTO → domain transformations
      types/                  # Feature-local types
      index.ts                # Public API — export only what others need
  lib/
    domain/                   # Cross-feature pure business logic
    api/                      # Shared API client utilities
  types/                      # Shared TypeScript types
  hooks/                      # App-wide reusable hooks
```

**For scaling to a monorepo (when mobile is added):**
```
apps/web/        mobile/
packages/shared/ (domain, schemas, types, utils, constants)
         api-client/
```

**Rules:**
- `app/` has no business logic — routing only
- Features don't import from other features — go through `lib/` or `types/`
- `components/ui/` has no data fetching or domain logic

---

## Shared TypeScript Types

All shared types live in `src/types/`. Infer from Zod schemas — never write parallel type definitions.

```ts
// src/types/user.ts
export interface User { id: string; email: string; role: 'admin' | 'member' }

// Inferred from schema — no duplication
export type CreateUserInput = z.infer<typeof createUserSchema>
```

**Naming:** `CustomerDto` (API payload) · `Customer` (domain model) · `CustomerFormInput` (form values) — never blur these shapes.

---

## API Layer

All `fetch` calls live in `src/lib/api/` or `features/<name>/api/`. Never in components.

```ts
// src/lib/api/users.ts
export async function getUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  if (!res.ok) throw new Error('Failed to fetch user')
  return res.json()
}
```

Convert raw DTOs to domain shapes close to the API boundary using mappers:
```ts
// features/customers/mappers/mapCustomerDto.ts
export function mapCustomerDto(dto: CustomerDto): Customer { ... }
```

**Rules:** one file per resource · always handle non-ok responses · prefer server-side fetching for security, SEO, and performance · keep secrets and privileged operations server-side only.

---

## Validation

Zod schemas in `features/<name>/schemas/` (feature-local) or `src/lib/validation/` (shared). Reuse on client and server.

```ts
export const createUserSchema = z.object({
  email: z.string().email(),
  role: z.enum(['admin', 'member']),
})

// In API route handler:
const result = createUserSchema.safeParse(await req.json())
if (!result.success) return Response.json({ error: result.error.flatten() }, { status: 400 })
```

Pattern: `incoming payload → validate → map → domain object` · `form submit → validate → transform → submit`

---

## Domain / Business Logic

Pure functions — no UI, no fetch, no side effects. Fully testable. Lives in `lib/domain/` (shared) or `features/<name>/domain/` (local).

```ts
export function canEditPost(user: User, authorId: string): boolean {
  return user.role === 'admin' || user.id === authorId
}
```

**Shared code rules** (portable to mobile later): no DOM APIs · no Next.js-specific APIs · no UI imports · fully typed · deterministic.

---

## Component Patterns

```ts
interface ButtonProps { label: string; onClick: () => void; disabled?: boolean }

export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{label}</button>
}
```

- Named exports only in `components/` — no default exports
- Props interface in same file as component
- Handlers prefixed with `handle`: `handleSubmit`, `handleClose`
- No prop drilling beyond 2 levels — use context or lift state to feature

---

## Server vs Client (Next.js)

Default to **server components**. Use `"use client"` only when needed for browser APIs, interactive state, event handlers, or complex client hooks.

- Keep `"use client"` boundaries as small as possible
- Never pull server-only logic (DB, tokens, secrets) into client bundles

---

## Naming Conventions

| Type | Example |
|---|---|
| Component | `CustomerCard.tsx` |
| Hook | `useCustomerFilters.ts` |
| Schema | `customer.schema.ts` |
| Mapper | `mapCustomerDtoToCustomer.ts` |
| Server action | `createCustomerAction.ts` |
| Types file | `customer.types.ts` |

---

## State Management

- **Local UI state** → `useState` / `useReducer`
- **Server state** → TanStack Query (caching, refetching, loading)
- **Global UI state** (modals, toasts, theme) → React Context in `app/` layout
- **Avoid** Redux/Zustand unless the above genuinely isn't enough

Keep business rules outside the state container.

---

## Scaling Tiers

**Small (< 5 features):** flat `components/`, `lib/`, `types/` — skip feature folders.

**Growing (5+ features):** introduce `features/<name>/` · barrel `index.ts` exports · React Context per feature.

**Large (10+ features, 3+ devs):** enforce feature boundary rule strictly · add `services/` for cross-domain orchestration · consider Turborepo monorepo.

---

## Testing

- Unit tests for all `lib/domain/` and mapper functions
- Component tests (React Testing Library) for `components/` and `features/`
- e2e tests (Playwright) for critical user journeys
- Test files colocated: `CustomerCard.test.tsx` next to `CustomerCard.tsx`

Priority: domain logic → mappers → validation → critical flows → API client behavior → presentational components (lowest).

---

## What to Avoid

- Business logic directly in page files
- God-components that fetch, transform, validate, and render
- Global state library without clear need
- Mixing DTOs, form models, and domain models carelessly
- Cross-feature imports (bypass `index.ts`)
- Shared code coupled to Next.js or browser APIs
- Over-engineering mobile support before it's needed

---

## Decision Rule

> **Will this be reused across web and mobile?** → shared portable logic
> **Tied to rendering or browser interaction?** → web UI only
> **Sensitive or privileged?** → server only

**Final rule: build for today, structure for tomorrow.**

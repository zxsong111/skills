# API / interface design

**Applies when:** Has an external HTTP / RPC / GraphQL interface

**Probe first:** Route definitions, OpenAPI / proto files, how existing endpoints handle naming and pagination

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Resource naming | Plural nouns, kebab-case paths; RPC uses verb-object | `GET /orders/{id}` |
| Versioning | URL prefix or header; when to bump the major version | `/v1/` |
| Pagination / filtering / sorting | Uniform parameter names and response shape | `?cursor=&limit=`, returns `next_cursor` |
| Idempotency | Write operations support `Idempotency-Key`; PUT/DELETE are idempotent by nature | none |
| Backward compatibility | Add only, never remove; deprecate a field for one version cycle before removing it | none |
| Contract first | Change the OpenAPI / proto before changing the implementation | none |

## Where it lands

- Layer 2: with OpenAPI / proto, add linting (spectral, buf lint) and breaking-change checks (buf breaking, oasdiff) to CI
- Layer 3: `.claude/rules/api.md`, with `paths:` scoped to the route / handler directories

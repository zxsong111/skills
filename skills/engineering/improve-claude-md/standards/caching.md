# Caching

**Applies when:** Uses Redis / Memcached / in-memory cache / CDN

**Probe first:** How the cache client is used, existing key format and TTLs

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Key naming | `<service>:<entity>:<id>:<version>` | `order:summary:123:v2` |
| TTL | A TTL for each kind of data; nothing without an expiry | none |
| Invalidation | After a write, delete the cache or update it; spell out the order | none |
| Penetration / breakdown | Cache empty results, rebuild under a mutex | none |

## Where it lands

- Layer 3: `.claude/rules/caching.md`, with `paths:` scoped to cache-related modules

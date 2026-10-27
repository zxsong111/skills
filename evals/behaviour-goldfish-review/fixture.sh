#!/bin/bash
# A tiny repo with a design doc that plants two problems for the goldfish
# reviewers: it uses the term "tenant envelope" without defining it anywhere
# (reader), and it claims `parseLimit` in src/limits.js returns a number when the
# code returns a string (code-fit). GLOSSARY.md exists and deliberately does not
# define the term, so the reader cannot resolve it from the context files.
set -e
git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p docs/designs src
cat > GLOSSARY.md <<'GLOSS'
# Glossary

**Limit**: the maximum number of requests a caller may make per window.
GLOSS
cat > src/limits.js <<'JS'
/**
 * Parse a limit header value such as "100/min".
 * @param {string} raw
 * @returns {string} the numeric part, still as a string
 */
function parseLimit(raw) {
  return raw.split("/")[0];
}

module.exports = { parseLimit };
JS
cat > docs/designs/rate-limiter.md <<'DOC'
# Design: per-caller rate limiter

## Goals

- Reject a caller that exceeds its limit within a one-minute window.
- Reuse the existing `parseLimit` helper in `src/limits.js`, which returns the limit as a number, so the new code can compare it directly against the request count.

## Plan

1. Add `src/rate-limiter.js` exporting `check(callerId, tenantEnvelope)`.
2. On each request, read the limit from the tenant envelope, call `parseLimit`, and compare the result with the count stored for the caller.
3. Return `{ allowed: boolean, remaining: number }`.

## Out of scope

- Distributed counters. One process only for now.
DOC
git add -A
git commit -qm "add limits helper and rate limiter design"

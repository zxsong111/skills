# Frontend

**Applies when:** Has a web / mobile UI

**Probe first:** Framework, state management library, styling approach, component directory, existing a11y tooling

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Component granularity | The split between presentational and container components; a line cap per component | none |
| State | What handles local state / global state / server cache | React Query handles server data |
| Styling | One approach, never mixed | Tailwind, no inline styles |
| a11y | Interactive elements work by keyboard, images have alt, forms have labels | none |
| Verification | After a UI change, start the local server and check the real page and the console, not just that the build passes | none |

## Where it lands

- Layer 2: eslint-plugin-jsx-a11y and the like
- Layer 3: `.claude/rules/frontend.md`, with `paths:` scoped to the frontend directories

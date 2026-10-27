#!/bin/bash
# A repo on main with one staged change, so "commit this" has something to commit.
set -e
git init -q -b main
git config user.email eval@example.com
git config user.name eval
printf 'export function add(a, b) {\n  return a + b;\n}\n' > math.js
git add math.js
git commit -qm "add math.js"
printf 'export function add(a, b) {\n  return a + b;\n}\n\nexport function sub(a, b) {\n  return a - b;\n}\n' > math.js
git add math.js

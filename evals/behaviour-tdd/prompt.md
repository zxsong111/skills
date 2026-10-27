---
description: Asking for test-first work should load tdd and produce the red-green order, writing the test, running it, and only then writing the implementation. Needs --allow-tools Write Edit "Bash(node *)".
tags: [behaviour]
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

In this empty directory, build a tiny Node module test-first, one red-green slice at a time.

- The module is `slugify.js`, exporting `slugify(text)` with CommonJS (`module.exports`). It lowercases the text, replaces runs of spaces and punctuation with a single `-`, and trims leading and trailing `-`. For example `slugify("Hello, World!")` is `"hello-world"`.
- The tests go in `slugify.test.js`, written with the built-in `node:test` module and `node:assert`, run with `node --test`.

Write the first failing test and run it before any implementation exists. Finish with all tests green, and paste the last lines of the final test run.

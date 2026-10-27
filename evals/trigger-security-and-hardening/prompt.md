---
description: A file-upload endpoint is on the skill's trigger list, so planning it should load security-and-hardening.
tags: [trigger]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

We have an Express API. Plan an endpoint `POST /users/:id/avatar` that accepts an image upload from the browser and stores it on disk under `uploads/`. List the steps and the middleware you would add. Do not write the code yet.

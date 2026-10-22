#!/usr/bin/env node
// Check that every promoted skill is wired up consistently. Read-only.
//
// Usage: npm run check-skills
//
// What it verifies:
//   1. The promoted set agrees five ways: .claude-plugin/plugin.json,
//      skills/<bucket>/ dirs on disk, top-level README links, and each
//      bucket README's links.
//   2. docs/<bucket>/<name>.md exists for every promoted skill. The
//      reverse is allowed: an orphan docs page is how an archived skill
//      stays documented after removal.
//   3. Invocation pairing: disable-model-invocation: true in SKILL.md
//      frontmatter iff agents/openai.yaml sets
//      policy.allow_implicit_invocation: false.
//   4. ask-matt mentions every user-invoked skill.
//   5. SKILLS-MAP.md mentions every promoted skill (one direction only:
//      the map also covers non-promoted skills).
//   6. claude plugin validate . reports nothing beyond the two known
//      upstream warnings (root CLAUDE.md, missing icon). Skipped when
//      the claude CLI is not installed.
//
// Non-promoted buckets (misc/, in-progress/, deprecated/) must stay out
// of plugin.json and the READMEs; links to them are reported as errors.
//
// Exit code 0 when everything is wired, 1 otherwise.

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const BUCKETS = ['engineering', 'productivity'];
const NON_PROMOTED = ['misc', 'in-progress', 'deprecated'];
const KNOWN_VALIDATE_WARNINGS = 2;

const problems = [];

function read(path) {
  return existsSync(path) ? readFileSync(path, 'utf8') : null;
}

function pushProblems(list) {
  problems.push(...list);
}

// --- 1. The five-way set: plugin.json, disk, top README, bucket READMEs ---

const plugin = JSON.parse(read(join(ROOT, '.claude-plugin/plugin.json')));
const declared = plugin.skills.map((p) => p.replace(/^\.\//, '')).sort();

const onDisk = [];
const diskByBucket = {};
for (const bucket of BUCKETS) {
  diskByBucket[bucket] = [];
  const base = join(ROOT, 'skills', bucket);
  for (const entry of readdirSync(base, { withFileTypes: true })) {
    const isSkill = entry.isDirectory() && existsSync(join(base, entry.name, 'SKILL.md'));
    if (isSkill) {
      diskByBucket[bucket].push(entry.name);
      onDisk.push(`skills/${bucket}/${entry.name}`);
    }
  }
  diskByBucket[bucket].sort();
}
onDisk.sort();

function setDiff(left, right, label) {
  const missing = left.filter((x) => !right.includes(x));
  const extra = right.filter((x) => !left.includes(x));
  if (missing.length) pushProblems(missing.map((x) => `${x}: ${label} but not on disk`));
  if (extra.length) pushProblems(extra.map((x) => `${x}: on disk but not ${label}`));
}

setDiff(declared, onDisk, 'in plugin.json');

const topReadme = read(join(ROOT, 'README.md'));
const topLinks = [];
const linkRe = /\[[^\]]*\]\((?:\.\/)?(skills\/(?:engineering|productivity)\/[a-z0-9-]+)\/SKILL\.md\)/g;
for (const match of topReadme.matchAll(linkRe)) topLinks.push(match[1]);
topLinks.sort();
if (!topLinks.length) pushProblems('README.md: no promoted skill links found, link extraction may be broken');
setDiff(declared, topLinks, 'linked in top-level README');

for (const link of topReadme.matchAll(/\((?:\.\/)?skills\/(?:misc|in-progress|deprecated)\/[^)]*\)/g)) {
  pushProblems(`README.md links a non-promoted skill: ${link[0]}`);
}

for (const bucket of BUCKETS) {
  const text = read(join(ROOT, 'skills', bucket, 'README.md'));
  const names = [];
  for (const match of text.matchAll(/\[[^\]]*\]\(\.\/([a-z0-9-]+)\/SKILL\.md\)/g)) names.push(match[1]);
  names.sort();
  if (!names.length) pushProblems(`skills/${bucket}/README.md: no skill links found, link extraction may be broken`);
  setDiff(diskByBucket[bucket], names, `listed in skills/${bucket}/README.md`);
}

// --- 2. Docs pages exist for every promoted skill ---

for (const path of declared) {
  const name = path.split('/')[2];
  const docs = join(ROOT, 'docs', path.split('/')[1], `${name}.md`);
  if (!existsSync(docs)) pushProblems(`${name}: no docs page at docs/${path.split('/')[1]}/${name}.md`);
}

// --- 3. Invocation pairing and 4. ask-matt coverage ---

const askMatt = read(join(ROOT, 'skills', 'engineering', 'ask-matt', 'SKILL.md'));
const userInvoked = [];

for (const path of declared) {
  const dir = join(ROOT, path);
  const frontmatter = /^---\r?\n([\s\S]*?)\r?\n---/.exec(read(join(dir, 'SKILL.md')));
  const isUserInvoked = !!frontmatter && /(^|\n)\s*disable-model-invocation:\s*true\b/.test(frontmatter[1]);

  const yamlPath = join(dir, 'agents', 'openai.yaml');
  const yaml = read(yamlPath);
  const yamlSaysImplicitFalse = !!yaml && /allow_implicit_invocation:\s*false/.test(yaml);

  if (isUserInvoked) userInvoked.push(path.split('/')[2]);
  if (isUserInvoked && !yaml) {
    pushProblems(`${path.split('/')[2]}: SKILL.md is user-invoked but agents/openai.yaml is missing`);
  } else if (isUserInvoked !== yamlSaysImplicitFalse) {
    pushProblems(
      `${path.split('/')[2]}: invocation mismatch, SKILL.md ${isUserInvoked ? 'says' : 'does not say'} ` +
        `disable-model-invocation but agents/openai.yaml ${yamlSaysImplicitFalse ? 'says' : 'does not say'} ` +
        `allow_implicit_invocation: false`,
    );
  }
}

for (const name of userInvoked.sort()) {
  const mentioned = new RegExp(`(^|[^a-z0-9-])${name}([^a-z0-9-]|$)`).test(askMatt);
  if (!mentioned) pushProblems(`${name}: user-invoked but not mentioned in ask-matt/SKILL.md`);
}

// --- 5. SKILLS-MAP membership ---

const skillsMap = read(join(ROOT, 'SKILLS-MAP.md'));
for (const path of declared) {
  const name = path.split('/')[2];
  const mentioned = new RegExp(`(^|[^a-z0-9-])${name}([^a-z0-9-]|$)`).test(skillsMap);
  if (!mentioned) pushProblems(`${name}: not mentioned in SKILLS-MAP.md`);
}

// --- 6. claude plugin validate, minus the known upstream warnings ---

let claudeOnPath = true;
try {
  execFileSync('claude', ['--version'], { stdio: 'pipe' });
} catch {
  claudeOnPath = false;
}
if (claudeOnPath) {
  let out = '';
  try {
    out = execFileSync('claude', ['plugin', 'validate', '.'], { cwd: ROOT, stdio: 'pipe' }).toString();
  } catch (err) {
    out = `${err.stdout || ''}${err.stderr || ''}`;
  }
  const warningCount = (out.match(/⚠/g) || []).length;
  if (warningCount > KNOWN_VALIDATE_WARNINGS) {
    pushProblems(
      `claude plugin validate reports ${warningCount} warnings, expected at most ${KNOWN_VALIDATE_WARNINGS} ` +
        `(root CLAUDE.md, missing icon). Run it manually to see what is new.`,
    );
  }
} else {
  console.log('check-skills: claude CLI not found, skipping the validate step');
}

// --- Report ---

if (problems.length) {
  console.error(`check-skills: ${problems.length} problem${problems.length === 1 ? '' : 's'} found`);
  for (const problem of problems) console.error(`  - ${problem}`);
  process.exit(1);
}

console.log(
  `check-skills: OK, ${declared.length} promoted skills wired ` +
    `(plugin.json, disk, READMEs, docs pages, invocation pairs, ask-matt, SKILLS-MAP)`,
);

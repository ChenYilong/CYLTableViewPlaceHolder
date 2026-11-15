#!/usr/bin/env node
// Checks the HarmonyOS example's texts: every literal key passed to t('...') in entry/src/main/ets exists in all seven
// languages of ExampleStrings.ets (generated from CYLScenarioExample.bundle), and every language has the same keys.
// Exit code 1 lists what is missing.
//
//   node scripts/harmony-l10n-check.js
'use strict'
const fs = require('fs')
const path = require('path')

const ROOT = path.join(__dirname, '..', 'CrossPlatform', 'harmonyos-cylplaceholder', 'entry', 'src', 'main', 'ets')
const STRINGS = path.join(ROOT, 'common', 'ExampleStrings.ets')
const source = fs.readFileSync(STRINGS, 'utf8')
const tables = {}
for (const m of source.matchAll(/const ExampleStrings(\w+): Record<string, string> = \{([\s\S]*?)\n\};/g)) {
  tables[m[1]] = new Set([...m[2].matchAll(/^\s+("(?:[^"\\]|\\.)*"):/gm)].map((k) => JSON.parse(k[1])))
}
const names = Object.keys(tables)
const problems = []
if (names.length !== 7) problems.push(`expected 7 languages, found ${names.length}: ${names.join(', ')}`)

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? walk(path.join(dir, e.name)) : e.name.endsWith('.ets') ? [path.join(dir, e.name)] : [])
}
const used = new Map()
for (const file of walk(ROOT)) {
  if (file === STRINGS) continue
  const text = fs.readFileSync(file, 'utf8')
  for (const m of text.matchAll(/\bt\(\s*'([A-Za-z0-9_.]+)'/g)) {
    if (!used.has(m[1])) used.set(m[1], path.relative(ROOT, file))
  }
}
for (const [key, file] of used) {
  const missing = names.filter((n) => !tables[n].has(key))
  if (missing.length) problems.push(`${key} (${file}) missing in ${missing.join(', ')}`)
}
const all = new Set(names.flatMap((n) => [...tables[n]]))
for (const n of names) {
  const gaps = [...all].filter((k) => !tables[n].has(k))
  if (gaps.length) problems.push(`${n} lacks ${gaps.length} keys other languages have: ${gaps.slice(0, 8).join(', ')}${gaps.length > 8 ? ', ...' : ''}`)
}
if (problems.length) {
  console.log(`HarmonyOS texts: ${problems.length} problem(s)`)
  problems.forEach((p) => console.log('- ' + p))
  process.exit(1)
}
console.log(`HarmonyOS texts: ${used.size} keys used, all present in ${names.length} languages (${tables[names[0]].size} keys each)`)

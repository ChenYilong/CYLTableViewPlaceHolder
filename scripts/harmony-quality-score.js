#!/usr/bin/env node
// Computes the HarmonyOS quality score of docs/HarmonyOS.md ("Full-marks standard"): the rows "| Q<n> | ..." whose
// last column starts with "完成 / Done" count as done; rows marked "n/a" are not counted. The score line between the
// harmony-quality markers is rewritten.
//
//   node scripts/harmony-quality-score.js          rewrite docs/HarmonyOS.md
//   node scripts/harmony-quality-score.js --score  print the score only
'use strict'

const fs = require('fs')
const path = require('path')

const DOC = path.join(__dirname, '..', 'docs', 'HarmonyOS.md')
const BEGIN = '<!-- harmony-quality:begin -->'
const END = '<!-- harmony-quality:end -->'

const text = fs.readFileSync(DOC, 'utf8')
const nl = text.includes('\r\n') ? '\r\n' : '\n'
let done = 0
let counted = 0
const open = []
const na = []
for (const line of text.split(/\r?\n/)) {
  const m = /^\| (Q\d+) \|/.exec(line)
  if (!m) continue
  const cells = line.split(' | ')
  const status = cells[cells.length - 1].replace(/\|\s*$/, '').trim()
  if (/^n\/a/i.test(status)) continue
  // Rows the owner marked "TODO: N/A on HarmonyOS" (with a reason) are listed but not counted.
  if (status.startsWith('TODO: N/A on HarmonyOS')) {
    na.push(m[1])
    continue
  }
  counted++
  if (status.startsWith('完成 / Done')) done++
  else open.push(m[1])
}
const score = counted === 0 ? 0 : Math.floor((done * 100) / counted)
const summary = `HarmonyOS quality score ${score} / 100: ${done} / ${counted} done` + (open.length ? ` (open: ${open.join(', ')})` : '') + (na.length ? ` (N/A on HarmonyOS, not counted: ${na.join(', ')})` : '')
if (process.argv.includes('--score')) {
  console.log(summary)
  process.exit(0)
}
const block = [
  BEGIN,
  '| 中文 | English |',
  '|:---|:---|',
  `| **鸿蒙质量分：${score} / 100**（完成 ${done} / 计入 ${counted} 项${open.length ? '；未完成：' + open.join('、') : ''}${na.length ? '；N/A on HarmonyOS，不计入：' + na.join('、') : ''}）。 | **HarmonyOS quality score: ${score} / 100** (${done} / ${counted} rows done${open.length ? '; open: ' + open.join(', ') : ''}${na.length ? '; N/A on HarmonyOS, not counted: ' + na.join(', ') : ''}). |`,
  END,
].join(nl)
const start = text.indexOf(BEGIN)
const end = text.indexOf(END)
if (start < 0 || end < 0) throw new Error('quality markers not found in ' + DOC)
fs.writeFileSync(DOC, text.slice(0, start) + block + text.slice(end + END.length))
console.log(summary)

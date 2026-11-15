#!/usr/bin/env node
// Writes the two tables of docs/HarmonyOS.md and their score:
//   1. every public symbol of the iOS library (the iOS column of docs/Android-API-Map.md, generated from the public
//      headers by scripts/android-api-map.py);
//   2. every demo of the iOS example Examples/Example-Scenarios (screen by screen, row by row; the lists come from the
//      1:1 WeChat Mini Program copy, CrossPlatform/wechat-miniprogram-cylplaceholder/example, which mirrors it).
// The second column is the HarmonyOS implementation, "TODO" until it exists. Re-running keeps every second column
// already written (matched by the first column), so the tables are edited by hand and this script only adds rows and
// recomputes the score: score = rows without TODO / counted rows (both tables together; "n/a" rows are not counted).
//
//   node scripts/harmony-port-tables.js          rewrite docs/HarmonyOS.md
//   node scripts/harmony-port-tables.js --score  print the score only
'use strict'

const fs = require('fs')
const path = require('path')

const ROOT = path.join(__dirname, '..')
const DOC = path.join(ROOT, 'docs', 'HarmonyOS.md')
const API_MAP = path.join(ROOT, 'docs', 'Android-API-Map.md')
const MP = path.join(ROOT, 'CrossPlatform', 'wechat-miniprogram-cylplaceholder')
const EX = path.join(MP, 'example', 'miniprogram')
const BEGIN = '<!-- harmony-tables:begin -->'
const END = '<!-- harmony-tables:end -->'

// ---- Table 1: iOS API ----
function apiRows() {
  const rows = []
  let file = null
  for (const line of fs.readFileSync(API_MAP, 'utf8').split(/\r?\n/)) {
    const h = /^## `(.+)`$/.exec(line)
    if (h) {
      file = h[1]
      continue
    }
    if (!file || !line.startsWith('| `')) continue
    const cells = line.split(' | ')
    const ios = cells[0].slice(2).trim()
    const note = (cells[3] || '').replace(/\|\s*$/, '').trim()
    // Symbols iOS itself marks unavailable (NS_UNAVAILABLE) have nothing to port.
    const unavailable = /unavailable on iOS too/.test(note)
    rows.push({ group: file, key: ios, value: unavailable ? 'n/a (NS_UNAVAILABLE on iOS)' : 'TODO' })
  }
  return rows
}

// ---- Table 2: iOS example demos ----
function exampleRows() {
  const en = require(path.join(EX, 'utils', 'strings', 'en.js'))
  const t = (k) => (en[k] != null ? String(en[k]).replace(/%[@d]|%ld|%\d\$@/g, 'N') : k)
  const { CYLPlaceholderScenarioCatalog: Catalog, CYLPlaceholderScenarioCategory } = require(path.join(MP, 'src', 'cyl-placeholder', 'cyl_placeholder'))
  const rows = []
  const add = (group, key) => rows.push({ group, key, value: 'TODO' })

  const shell = 'App shell (CYLScenarioAppDelegate, CYLTabBarController)'
  add(shell, 'Tab bar: Scenarios, Animations, Flows, Feed, Refresh and the raised teal plus button at index 3')
  add(shell, 'Publish (plus button): Uploading, then Success with Done')
  add(shell, 'Language menu (🌐): 7 languages + follow system, rebuilds the interface')

  const sc = 'Scenarios tab (CYLScenarioListViewController, CYLScenarioDetailViewController)'
  for (const s of Catalog.allScenarios) add(sc, 'Scenario `' + s + '`: ' + Catalog.localizedNameForScenario(s, 'en'))
  add(sc, 'Contact support page (CYLSupportViewController)')
  const files = fs.readdirSync(path.join(EX, 'configurations')).map((f) => f.replace(/\.json$/, '').replace(/\.plist$/, '.plist')).sort()
  for (const f of files) add(sc, 'Configuration file `' + f + '` (CYLConfigurationViewController)')
  add(sc, 'Configuration file raw text (CYLTextFileViewController)')

  const an = 'Animations tab (CYLAnimationListViewController, CYLAnimationDetailViewController)'
  const { sections } = require(path.join(EX, 'pages', 'animations', 'animation_list.js'))
  for (const s of sections) add(an, 'Animation files: ' + s.title + ' (' + (s.files || s.rows || []).length + ' files, detail replays every 4 s)')
  add(an, 'Sources (NOTICE.animations)')

  const fl = 'Flows tab (CYLFlowListViewController)'
  const flowSrc = fs.readFileSync(path.join(EX, 'pages', 'flows', 'flows.js'), 'utf8')
  for (const m of flowSrc.matchAll(/\{ flow: '(\w+)', key: '(\w+)', detail: '([^']*)'/g)) add(fl, 'Flow `' + m[1] + '`: ' + t(m[2]) + ' (' + m[3] + ')')
  const statusSrc = fs.readFileSync(path.join(EX, 'pages', 'status', 'status.js'), 'utf8')
  for (const m of statusSrc.matchAll(/\{ key: '(CYLScenarioStatusMode\w+)'/g)) add(fl, 'Network status bar (CYLStatusBarViewController): ' + t(m[1]))
  add(fl, 'Network status bar: follow the network, apply StatusBar/*.json files')
  const hudSrc = fs.readFileSync(path.join(EX, 'pages', 'hud', 'hud.js'), 'utf8')
  for (const m of hudSrc.matchAll(/\['(\w+)', '(CYLScenarioHUD\w+)', \d\]/g)) add(fl, 'HUD (CYLHUDViewController): ' + t(m[2]))
  add(fl, 'HUD life cycle (CYLHUDLifecycleViewController)')

  const fe = 'Feed tab (CYLFeedViewController)'
  add(fe, 'Feed: loading, 15 posts, every other refresh fails with RetryButton, load more to 30 then No more data')
  const { SECTIONS: ICONS } = require(path.join(EX, 'pages', 'refresh-icons', 'setups.js'))
  for (const s of ICONS) for (const r of s.rows) add(fe, 'Refresh icons (CYLRefreshIconListViewController): ' + (s.titleKey ? t(s.titleKey) : s.title) + ' · ' + (r.titleKey ? t(r.titleKey) : r.title))

  const re = 'Refresh tab (CYLRefreshExampleViewController)'
  const { SECTIONS: MENU } = require(path.join(EX, 'pages', 'refresh', 'menu.js'))
  for (const s of MENU) for (const r of s.rows) add(re, t(s.key) + ' · ' + t(r.key) + ' (' + r.vc + ' - ' + r.method + ')')
  return rows
}

// ---- Merge, score, render ----
function existingValues() {
  const values = new Map()
  if (!fs.existsSync(DOC)) return values
  for (const line of fs.readFileSync(DOC, 'utf8').split(/\r?\n/)) {
    const m = /^\| (.+?) \| (.+?) \|$/.exec(line)
    if (m && m[1] !== 'iOS API' && m[1] !== 'iOS 演示 / iOS demo' && !/^:?-+/.test(m[1])) values.set(m[1], m[2])
  }
  return values
}

function score(rows) {
  const counted = rows.filter((r) => !/^n\/a/.test(r.value))
  const done = counted.filter((r) => !/\bTODO\b/.test(r.value)).length
  return { done, counted: counted.length, na: rows.length - counted.length, score: counted.length ? Math.floor((done / counted.length) * 100) : 0 }
}

function table(rows, header) {
  const out = []
  let group = null
  for (const r of rows) {
    if (r.group !== group) {
      group = r.group
      out.push('', '#### ' + (header === 'iOS API' ? '`' + group + '`' : group), '', '| ' + header + ' | 鸿蒙对应实现 / HarmonyOS |', '|:---|:---|')
    }
    out.push('| ' + r.key + ' | ' + r.value + ' |')
  }
  return out.join('\n')
}

function main() {
  const old = existingValues()
  const keep = (rows) => rows.map((r) => (old.has(r.key) ? Object.assign(r, { value: old.get(r.key) }) : r))
  const api = keep(apiRows())
  const demos = keep(exampleRows())
  const all = score(api.concat(demos))
  const a = score(api)
  const d = score(demos)
  if (process.argv.includes('--score')) {
    console.log(JSON.stringify({ total: all, api: a, demos: d }))
    return
  }
  const block = [
    BEGIN,
    '<!-- Generated by scripts/harmony-port-tables.js; edit the second column by hand, then re-run it for the score. -->',
    '',
    '| 中文 | English |',
    '|:---|:---|',
    '| **鸿蒙完成度：' + all.score + ' / 100**（两张表合计：没有 TODO 的行 ' + all.done + ' / 计入的行 ' + all.counted + '；n/a ' + all.na + ' 行不计入）。API 表 ' + a.done + ' / ' + a.counted + '，演示表 ' + d.done + ' / ' + d.counted + '。 | **HarmonyOS score: ' + all.score + ' / 100** (both tables: rows without TODO ' + all.done + ' / counted rows ' + all.counted + '; ' + all.na + ' n/a rows not counted). API table ' + a.done + ' / ' + a.counted + ', demo table ' + d.done + ' / ' + d.counted + '. |',
    '',
    '### 表 1：iOS 公开 API / Table 1: iOS public API',
    table(api, 'iOS API'),
    '',
    '### 表 2：iOS example 演示 / Table 2: iOS example demos',
    table(demos, 'iOS 演示 / iOS demo'),
    '',
    END,
  ].join('\n')
  let doc = fs.readFileSync(DOC, 'utf8')
  const i = doc.indexOf(BEGIN)
  const j = doc.indexOf(END)
  doc = i >= 0 && j > i ? doc.slice(0, i) + block + doc.slice(j + END.length) : doc.trimEnd() + '\n\n' + block + '\n'
  fs.writeFileSync(DOC, doc)
  console.log('HarmonyOS score', all.score, '/ 100:', all.done, '/', all.counted, '(api', a.done + '/' + a.counted + ', demos', d.done + '/' + d.counted + ', n/a', all.na + ')')
}

main()

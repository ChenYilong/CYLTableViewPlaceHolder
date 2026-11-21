#!/usr/bin/env python3
"""[EN] Table B: the iOS -> Android parity table of CYLTableViewPlaceHolder, in English.

Lists every public iOS symbol (the inventory of scripts/android-api-map.py) with a description taken from its
documentation comment in the public headers and its Android counterpart from android/merged/api-map.json. The Android
column says TODO when the symbol has no Android counterpart yet (status planned) or when its note names missing work
(contains "TODO"); n/a rows are iOS only and are left out of the score.
Score = rows without TODO / rows that are not n/a; 100 only when no row says TODO.
Writes docs/iOS-Android-Parity.md; `--check` fails when the document is stale.

[CN] 表格 B：CYLTableViewPlaceHolder 的 iOS -> Android 对照表（英文）。列出全部 iOS 公开符号、取自公开头文件文档注释的描述，以及
android/merged/api-map.json 中的 Android 对应项。没有 Android 对应项（planned）或说明中含 TODO 时 Android 列为 TODO；n/a 仅 iOS，
不计分。评分 = 没有 TODO 的行 / 非 n/a 的行；没有任何 TODO 时才是 100。`--check` 在文档过期时失败。
"""
import importlib.util
import math
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC_PATH = os.path.join(ROOT, 'docs', 'iOS-Android-Parity.md')

_spec = importlib.util.spec_from_file_location('android_api_map', os.path.join(ROOT, 'scripts', 'android-api-map.py'))
amap = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(amap)

_kspec = importlib.util.spec_from_file_location('ios_api_map', os.path.join(ROOT, 'scripts', 'ios-api-map.py'))
kmap = importlib.util.module_from_spec(_kspec)
_kspec.loader.exec_module(kmap)

CJK = re.compile(r'[　-〿一-鿿＀-￯]')


def english_of(comment):
    """[EN] The English text of a documentation comment, or ''. [CN] 文档注释的英文部分，或 ''。"""
    text = re.sub(r'^\s*(/\*[*!]?|\*/|\*|///?<?)', '', comment, flags=re.M)
    text = text.replace('*/', ' ')
    text = ' '.join(text.split())
    if '[EN]' in text:
        text = text.split('[EN]', 1)[1]
        text = text.split('[CN]', 1)[0]
    elif CJK.search(text):
        # [EN] Keep the sentences that have no Chinese. [CN] 保留不含中文的句子。
        text = ' '.join(s for s in re.split(r'(?<=[.;])\s+', text) if not CJK.search(s))
    text = re.sub(r'@(param|return|note|discussion|see)\b.*', '', text).strip()
    if len(text) > 220:
        cut = text.rfind('. ', 0, 220)
        text = text[:cut + 1] if cut > 60 else text[:217].rstrip() + '...'
    return text.replace('|', '\\|')


def descriptions():
    """[EN] key -> English description, from the comment right above each declaration. [CN] 键 -> 声明上方注释的英文描述。"""
    found = {}
    for path in amap.public_headers():
        raw = open(os.path.join(ROOT, path), encoding='utf-8', errors='replace').read()
        owner = None
        pending = ''
        comment = None
        in_block = None
        for line in raw.split('\n'):
            stripped = line.strip()
            if in_block is not None:
                in_block.append(stripped)
                if '*/' in stripped:
                    comment = '\n'.join(in_block)
                    in_block = None
                continue
            if stripped.startswith('/*'):
                if '*/' in stripped:
                    comment = stripped
                else:
                    in_block = [stripped]
                continue
            if stripped.startswith('//'):
                comment = (comment + '\n' + stripped) if comment and comment.lstrip().startswith('//') else stripped
                continue
            code = amap.strip_comments(stripped).strip()
            if not code:
                continue
            code = (pending + ' ' + code).strip() if pending else code
            pending = ''
            declared = amap.owner_symbol(code)
            if declared:
                owner = declared[0]
                symbol = declared[1]
            elif code.startswith('@end'):
                owner, symbol = None, None
            elif code.startswith(('-', '+')) and re.match(r'[-+]\s*\(', code) and ';' not in code:
                pending = code
                continue
            else:
                symbol = amap.declaration_symbol(code, owner)
            if symbol:
                kind, sym_owner, name = symbol
                key = '%s %s' % (sym_owner, name) if sym_owner and kind in ('method', 'property') else name
                if comment and key not in found:
                    found[key] = english_of(comment)
            comment = None
    return found


def android_descriptions():
    """[EN] "CYLX.member" -> the first KDoc sentence of the Android declaration, without the iOS name in parentheses.
    [CN] "CYLX.member" -> Android 声明 KDoc 的第一句，去掉括号中的 iOS 名称。"""
    found = {}
    for _, key, _, sentence, _ in kmap.declarations():
        sentence = re.sub(r'\s*\((?:the )?(?:iOS )?`[^`]*`[^)]*\)', '', sentence).strip()
        if sentence and key not in found:
            found[key] = sentence
    return found


def is_todo(entry):
    return entry.get('status', 'planned') == 'planned' or 'TODO' in entry.get('note', '')


def counterpart(entry):
    status = entry.get('status', 'planned')
    android = entry.get('android', '')
    note = entry.get('note', '')
    if status == 'n/a':
        return 'n/a (iOS only%s)' % (': ' + note if note else '')
    if status == 'planned':
        return 'TODO' + (' — ' + note if note else '')
    cell = '`%s`' % android if android else '—'
    if 'TODO' in note:
        return 'TODO — %s; %s' % (cell, note)
    return cell + (' — ' + note if note else '')


def score(rows, mapping):
    counted = [r for r in rows if mapping.get(r['key'], {}).get('status', 'planned') != 'n/a']
    todo = sum(1 for r in counted if is_todo(mapping.get(r['key'], {})))
    total = len(counted)
    # [EN] Rounded down, so one TODO left never shows 100. [CN] 向下取整，剩一个 TODO 也不会显示 100。
    return (math.floor(100 * (total - todo) / total) if total else 0), total, todo


def fallback_description(row):
    kinds = {'class': 'Class', 'category': 'Category', 'protocol': 'Protocol', 'constant': 'Constant', 'enum': 'Enumeration',
             'typedef': 'Type', 'function': 'Function', 'method': 'Method of `%s`' % row['owner'],
             'property': 'Property of `%s`' % row['owner']}
    return kinds.get(row['kind'], row['kind'].capitalize()) + '.'


def document(rows, mapping):
    texts = descriptions()
    android_texts = android_descriptions()
    percent, total, todo = score(rows, mapping)
    out = ['# iOS → Android parity (table B)', '',
           '<!-- bound-classes: none -->', '',
           '<!-- Generated by scripts/ios-android-parity.py from the public headers and android/merged/api-map.json; do not edit by hand. -->', '',
           'Every public API and feature of the iOS library (the public headers under `CYLTableViewPlaceHolder/`, CYLRefresh '
           'included), what it does (from its header comment, else from the Android counterpart\'s KDoc), and its Android counterpart in `android/` (Kotlin). This table is written in English '
           'only, as the task asked; the bilingual status table is [Android-API-Map.md](Android-API-Map.md) and the '
           'reverse table (Android → iOS, table A) is [iOS-API-Map.md](iOS-API-Map.md).', '',
           'Scoring: a row is TODO when it has no Android counterpart yet or its note names missing work. '
           '**Score = rows without TODO / counted rows**, rounded down; no TODO is 100, all TODO is 0. '
           'Rows marked n/a are iOS only (UIKit categories, the Lottie / PAG / Rive runtimes...) and are not counted.', '',
           '**Score: %d / 100** (%d counted rows, %d TODO, %d n/a).' % (percent, total, todo, len(rows) - total), '']
    by_header = {}
    for row in rows:
        by_header.setdefault(row['header'], []).append(row)
    for header in sorted(by_header):
        out += ['## `%s`' % header.replace('CYLTableViewPlaceHolder/', '', 1), '',
                '| iOS API / feature | Description | Android counterpart |', '|:---|:---|:---|']
        for row in by_header[header]:
            entry = mapping.get(row['key'], {})
            ios = ('`%s`' % row['name'] if row['kind'] in ('class', 'category', 'protocol', 'constant', 'enum', 'typedef', 'function')
                   else '`%s` `%s`' % (row['owner'], row['name']))
            text = (texts.get(row['key']) or android_texts.get(kmap.normalize(entry.get('android', '')))
                    or fallback_description(row))
            out.append('| %s | %s | %s |' % (ios, text, counterpart(entry).replace('|', '\\|')))
        out.append('')
    return '\n'.join(out)


def main():
    rows = amap.inventory()
    mapping = amap.load_map()
    text = amap.with_navigation_of('', document(rows, mapping))
    current = open(DOC_PATH, encoding='utf-8').read() if os.path.exists(DOC_PATH) else ''
    percent, total, todo = score(rows, mapping)
    if '--check' in sys.argv:
        if current.rstrip('\n') != text.rstrip('\n'):
            print('docs/iOS-Android-Parity.md is out of date: run python3 scripts/ios-android-parity.py')
            return 1
        print('docs/iOS-Android-Parity.md is up to date (score %d, %d TODO of %d).' % (percent, todo, total))
        return 0
    with open(DOC_PATH, 'w', encoding='utf-8') as handle:
        handle.write(amap.with_navigation_of(current, text))
    print('wrote docs/iOS-Android-Parity.md: score %d, %d TODO of %d counted rows' % (percent, todo, total))
    return 0


if __name__ == '__main__':
    sys.exit(main())
